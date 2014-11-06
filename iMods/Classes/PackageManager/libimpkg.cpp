//
//  libimpkg.cpp
//  iMods
//
//  Created by Ryan Feng on 9/20/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#include "libimpkg.h"
#include <algorithm>
#include <numeric>
#include <cctype>
#include <iostream>
#include <tuple>
#include <sstream>
#include <functional>
#include <unordered_map>
#include <cassert>
#include "zipstream.hpp"

#pragma mark -

std::string depTuplePackageName(const PackageDepTuple& dep) {
    return std::get<0>(dep);
}

PackageVersionOp depTupleVersionOp(const PackageDepTuple& dep) {
    return std::get<1>(dep);
}

std::string depTupleVersion(const PackageDepTuple& dep) {
    return std::get<2>(dep);
}

std::ostream& operator<<(std::ostream& stream, const PackageDepTuple& dep) {
    std::string verOp;
    switch (depTupleVersionOp(dep)) {
        case VER_ANY:
            verOp = "any";
            break;
            
        case VER_EQ:
            verOp = "=";
            break;
            
        case VER_GE:
            verOp = ">=";
            break;
            
        case VER_GT:
            verOp = ">";
            break;
            
        case VER_LE:
            verOp = "<=";
            break;
        
        case VER_LT:
            verOp = "<";
            break;
        
        default:
            break;
    }
    stream << "'" << depTuplePackageName(dep) << "' " << verOp << " " << depTupleVersion(dep);
    return stream;
}

#pragma mark -

int pkgVerComponentCmp(const std::string& v1, const std::string& v2){
    if(v1.empty() && v2.empty()) {
        return 0;
    } else if(v1.empty()) {
        if(v2[0] == '~'){
            return 1;
        }
        return -1;
    } else if(v2.empty()) {
        if(v1[0] == '~') {
            return -1;
        }
        return 1;
    }
    
    auto chOrder = [](char ch){
        return (ch == '~' ? -1
                : isdigit(ch) ? 0
                : ch == 0 ? 0
                : isalpha(ch) ? ch
                : ch+256);
    };
    auto pv1 = v1.begin();
    auto pv2 = v2.begin();
    while (pv1 != v1.end() && pv2 != v2.end()) {
        
        while (pv1 != v1.end() && pv2 != v2.end()
               && (!isdigit(*pv1) || !isdigit(*pv2))) {
            
            int orderV1 = chOrder(*pv1);
            int orderV2 = chOrder(*pv2);
            if(orderV1 != orderV2){
                return orderV1 - orderV2;
            }
            
            pv1++;
            pv2++;
        }
        
        while (*pv1 == '0') { pv1++; }
        while (*pv2 == '0') { pv2++; }
        
        int firstCmp = 0;
        
        while (pv1 != v1.end() && pv2 != v2.end()
               && (isdigit(*pv1) && isdigit(*pv2))) {
            
            if(firstCmp == 0) {
                firstCmp = *pv1 - *pv2;
            }
            
            pv1++;
            pv2++;
        }
        
        if (isdigit(*pv1)) {
            return 1;
        }
        
        if (isdigit(*pv2)) {
            return -1;
        }
        
        if (firstCmp) {
            return firstCmp;
        }
    }
    
    if(pv1 == v1.end() && pv2 == v2.end()) {
        return 0;
    } else if(pv1 == v1.end()) {
        if(*pv2 == '~'){
            return 1;
        }
        return -1;
    } else if(pv2 == v2.end()) {
        if(*pv1 == '~') {
            return -1;
        }
        return 1;
    }
    
    return 9999999; // Not possible
}

int pkgVersionCmp(const std::string& v1, const std::string& v2) {
    // Get epoch
    std::string epoch1, epoch2;
    
    auto pv1 = v1.begin();
    auto pv2 = v2.begin();
    auto epoch_end1 = pv1, epoch_end2 = pv2;
    
    while (isnumber(*epoch_end1)) {
        epoch_end1++;
    }
    
    while (isnumber(*epoch_end2)) {
        epoch_end2++;
    }
    
    if (epoch_end1 != v1.end() && *epoch_end1 == ':') {
        epoch1 = std::string(pv1, epoch_end1);
        pv1 = epoch_end1 + 1; // Skip the ':'
    }
    
    if (epoch_end2 != v2.end() && *epoch_end2 == ':') {
        epoch2 = std::string(pv2, epoch_end2);
        pv2 = epoch_end2 + 1; // Skip the ':'
    }
    
    // Compare epoch
    int epochCmp = atoi(epoch1.c_str()) - atoi(epoch2.c_str());
    if (epochCmp != 0) {
        return epochCmp;
    }
    
    // Get pacakge version
    std::string pkgV1, pkgV2;
    
    // Find the last '-'
    auto pkgVerEnd1 = v1.begin();
    
    auto pkgVerEnd2 = v2.begin();
    
    auto rend1 = v1.rfind('-');
    
    auto rend2 = v2.rfind('-');
    
    if (rend1 != std::string::npos) {
        pkgVerEnd1 += rend1;
    } else {
        pkgVerEnd1 = v1.end();
    }
    
    if (rend2 != std::string::npos) {
        pkgVerEnd2 += rend2;
    } else {
        pkgVerEnd2 = v2.end();
    }
    
    pkgV1 = std::string(pv1, pkgVerEnd1);
    pkgV2 = std::string(pv2, pkgVerEnd2);
    
    int cmp = pkgVerComponentCmp(pkgV1, pkgV2);
    if (cmp != 0) {
        return cmp;
    }
    
    // Get revision numbers and compare them
    pv1 = pkgVerEnd1;
    pv2 = pkgVerEnd2;
    if(pkgVerEnd1 != v1.end()) {
        pv1 = pkgVerEnd1 + 1;
    }
    
    if(pkgVerEnd2 != v2.end()) {
        pv2 = pkgVerEnd2 + 1;
    }
    auto pkgRevVer1 = std::string(pv1, v1.end());
    auto pkgRevVer2 = std::string(pv2, v2.end());
    return pkgVerComponentCmp(pkgRevVer1, pkgRevVer2);
}

#pragma mark -

enum PackageDepTokenType {
    TK_PKG,
    TK_OP,
    TK_VER,
    TK_SEP, // Separator ','
    TK_OR,
    TK_ANY,
    TK_EOF
};

typedef std::pair<PackageDepTokenType, std::string> PackageDepToken;


PackageDepToken nextToken(std::istringstream& sstream, PackageDepTokenType expected) {
    static std::string pkgNameChars = "+-.";
    static std::string pkgVerChars = "+-.~:";
    static std::string opChars = "<>=";
    
    // Predicates
    auto isPkgNameChar = [](char ch) {
        return isalnum(ch) || std::find(pkgNameChars.begin(), pkgNameChars.end(), ch) != pkgNameChars.end();
    };
    
    auto isPkgVerChar = [](char ch) {
        return isalnum(ch) || std::find(pkgVerChars.begin(), pkgVerChars.end(), ch) != pkgVerChars.end();
    };
    
    auto isOpChar = [](char ch) {
        return std::find(opChars.begin(), opChars.end(), ch) != opChars.end();
    };
    
    
    PackageDepTokenType tk_type;
    
    std::string token;
    
    char nch;
    
    std::function<int(char)> tkPred = nullptr;
    
parse_begin:
    
    // Remove leading spaces
    while (!sstream.eof() && isspace(sstream.peek())) {
        char ch = sstream.get();
    }
    if (sstream.eof()) {
        return std::make_pair(TK_EOF, "");
    }
    
    nch = sstream.peek();
    
    // Determine token type
    if (isPkgNameChar(nch)) {
        if (expected == TK_PKG) {
            tk_type = TK_PKG;
            tkPred = isPkgNameChar;
        } else if (expected == TK_VER) {
            tk_type = TK_VER;
            tkPred = isPkgVerChar;
        }
    } else if (isOpChar(nch)) {
        tk_type = TK_OP;
        tkPred = isOpChar;
    } else if (isPkgVerChar(nch)) {
        tk_type = TK_VER;
        tkPred = isPkgVerChar;
    } else if (nch == ',') {
        tk_type = TK_SEP;
        token = nch;
        sstream.get();
    } else if (nch == '|') {
        tk_type = TK_OR;
        token = nch;
        sstream.get();
    } else if (nch == '(' || nch == ')') {
        // Consume the parathesis
        sstream.get();
        goto parse_begin;
    } else if (nch == '[') {
        // Skip architecture restrictions
        while (!sstream.eof() && nch != ']') {
            nch = sstream.get();
        }
        goto parse_begin;
    } else {
        tk_type = TK_ANY;
    }

    // If it's a separater(',' or '|'), return
    if (tkPred == nullptr) {
        return std::make_pair(tk_type, token);
    }
    
    // Get the entire token
    while (true) {
        nch = sstream.peek();
        if (sstream.eof() || !tkPred(nch)) {
            break;
        }
        token += nch;
        sstream.get();
    }
    return std::make_pair(tk_type, token);
}

std::vector<std::vector<PackageDepTuple>> parseDepString(const std::string& depString) {
    std::istringstream sstream(depString);
    std::vector<PackageDepTuple> group;
    std::vector<std::vector<PackageDepTuple>> result;
    
    if (depString.empty()) {
        return result;
    }
    
    std::string targetPkg;
    std::string targetVer;
    PackageVersionOp targetOp = VER_ANY;
    bool parseDone = false;
    while (!parseDone) {
        PackageDepTokenType tkType;
        if (targetPkg.empty()) {
            tkType = TK_PKG;
        } else {
            tkType = TK_VER;
        }
        PackageDepToken token = nextToken(sstream, tkType);
        
        switch (token.first) {
            case TK_PKG:
                targetPkg = token.second;
                break;
            case TK_OP:
                if(token.second == "<<") {
                    targetOp = VER_LT;
                } else if(token.second == "=") {
                    targetOp = VER_EQ;
                } else if(token.second == ">>") {
                    targetOp = VER_GT;
                } else if(token.second == "<=") {
                    targetOp = VER_LE;
                } else if(token.second == ">=") {
                    targetOp = VER_GE;
                }
                break;
            case TK_VER:
                targetVer = token.second;
                break;
            case TK_SEP:
                std::transform(targetPkg.begin(), targetPkg.end(), targetPkg.begin(), ::tolower);
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                result.push_back(std::move(group));
                group.clear();
                targetPkg.clear();
                targetVer.clear();
                targetOp = VER_ANY;
                break;
            case TK_OR:
                std::transform(targetPkg.begin(), targetPkg.end(), targetPkg.begin(), ::tolower);
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                targetPkg.clear();
                targetVer.clear();
                targetOp = VER_ANY;
                break;
            case TK_EOF:
                std::transform(targetPkg.begin(), targetPkg.end(), targetPkg.begin(), ::tolower);
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                result.push_back(std::move(group));
                parseDone = true;
                break;
            default:
                break;
        }
    }
    return result;
}

/* TagParser is used to parse index or status files.
 * It's invoked by TagFile when the file is loaded.
 */
class TagParser {
    
public:
    
    TagParser(std::istream& tagfile);
    
    bool nextSection(TagSection& section);

private:
    
    bool nextTag(std::string& tag, std::string& value);
    std::istream& m_tagFile;
    size_t m_bufPtr;
};

#pragma mark -

TagParser::TagParser(std::istream& tagfile):m_tagFile(tagfile), m_bufPtr(0) {
    
}

bool TagParser::nextTag(std::string& tag, std::string& value) {
    std::string linebuf;
    if (linebuf.length() == 0) {
        std::getline(m_tagFile, linebuf);
    }
    if (linebuf.empty()) {
        return false;
    }
    std::string tagname, tagvalue;
    auto p = linebuf.begin();
    while (p != linebuf.end()) {
        if (!m_tagFile) {
            tag = tagname;
            value = tagvalue;
            return false;
        }
        // Count leading spaces
        size_t leadingSpaceCount = 0;
        while (p != linebuf.end() && std::isspace(*p)) {
            leadingSpaceCount++;
            p++;
        }
        // Empty lines(including lines consist of whitespaces) separate sections
        if (leadingSpaceCount == linebuf.length()) {
            tag = tagname;
            value = tagvalue;
            return false;
        }
        // Ignore comments
        if (linebuf[0] == '#') {
            std::getline(m_tagFile, linebuf);
            p = linebuf.begin();
            continue;
        } else if (std::isspace(linebuf[0])) {
            // A continuation line
            tagvalue += linebuf.substr(1);
            if(' ' == m_tagFile.peek()) {
                std::getline(m_tagFile, linebuf);
                p = linebuf.begin();
                continue;
            } else {
                tag = tagname;
                value = tagvalue;
                return true;
            }
        }
        
        auto isNonControlChar = [](char ch) {
            return (ch >= 33 && ch <= 57) || (ch >= 59 && ch <= 126);
        };
        
        // Parse tag name, it's followed by a colon ':' without quotes
        std::string token;
        while(p != linebuf.end() && isNonControlChar(*p)) {
            token += *p;
            p++;
        }
        // tagname should be followed by a ':', otherwise it's invalid
        if (*p == ':') {
            tagname = token;
            p++;
        } else {
            std::cerr << "Invalid line '" << linebuf << "'" << std::endl;
            return false;
        }
        // Ignore whitespaces before the value
        while (p != linebuf.end() && isspace(*p)) {
            p++;
        }
        // The rest of the line is the value
        token = linebuf.substr(p-linebuf.begin());
        p = linebuf.end();
        if (token.length() == 0) {
            tagvalue = "";
        } else {
            tagvalue = token;
        }
        // Look at next char and see if it's a continuation line
        if (' ' == m_tagFile.peek()) {
            std::getline(m_tagFile, linebuf);
            continue;
        }
    }
    tag = tagname;
    value = tagvalue;
    return true;
}

bool TagParser::nextSection(TagSection& tagsection) {
    std::string tagname, tagvalue;
    TagSection section(nullptr);
    while (!m_tagFile.eof() && nextTag(tagname, tagvalue)) {
        // Tag names are case insensitive, so we convert it to lower case here.
        std::transform(tagname.begin(), tagname.end(), tagname.begin(), ::tolower);
        section << TagField(tagname, tagvalue);
    }
    if (section.fieldCount() == 0) {
        return false;
    }
    tagsection = std::move(section);
    return true;
}

#pragma mark -

TagSection::TagSection(TagSection* next):m_next(next) {

}

TagSection::TagSection():m_next(nullptr) {
    
}

TagSection::TagSection(const TagSection& other) {
    m_mapping = other.m_mapping;
    m_next = other.m_next;
}

TagSection::TagSection(const TagSection&& other) {
    m_mapping = std::move(m_mapping);
    m_next = other.m_next;
}

TagSection& TagSection::operator=(const TagSection& other) {
    m_mapping = other.m_mapping;
    m_next = other.m_next;
    return *this;
}

TagSection::~TagSection() {
    
}

TagSection* TagSection::next() {
    return m_next;
}

void TagSection::setNext(TagSection* next) {
    m_next = next;
}

bool TagSection::tag(const std::string& tagname, std::string& out_tagvalue) const {
    std::string lowerTagname = tagname;
    std::transform(lowerTagname.begin(), lowerTagname.end(), lowerTagname.begin(), tolower);
    if (m_mapping.find(lowerTagname) != m_mapping.end()) {
        out_tagvalue = m_mapping.at(lowerTagname);
        return true;
    }
    return false;
}

TagSection& TagSection::operator<<(const TagField& field) {
    if(!field.first.empty()){
        // Ignore empty tag names, but values can be empty
        m_mapping.insert(field);
    }
    return *this;
}

const std::string& TagSection::operator[] (const std::string& tagname) {
    std::string lowerTagname = tagname;
    std::transform(lowerTagname.begin(), lowerTagname.end(), lowerTagname.begin(), ::tolower);
    return m_mapping[lowerTagname];
}

size_t TagSection::fieldCount() const {
    return m_mapping.size();
}

#pragma mark -

FilterCondition::FilterCondition(const TagField& srcField, FilterCondition::FilterOperator op)
: m_srcField(srcField), m_op(op){
    
}

FilterCondition::~FilterCondition() {
    
}

bool FilterCondition::matchSection(const TagSection& section) const {
    std::string tagvalue;
    if(section.tag(m_srcField.first, tagvalue)) {
        return matchTag(m_srcField.first, tagvalue);
    }
    return false;
}

bool FilterCondition::matchTag(const std::string& tagname, const std::string& tagvalue) const {
    const std::string& srcvalue = m_srcField.second;
    switch (m_op) {
        case TAG_EQ:
            return tagvalue == srcvalue;
            break;
        case TAG_NE:
            return tagvalue != srcvalue;
            break;
        case TAG_A_LT:
            return srcvalue < tagvalue;
            break;
        case TAG_A_GT:
            return srcvalue > tagvalue;
            break;
        case TAG_A_LE:
            return srcvalue <= tagvalue;
            break;
        case TAG_A_GE:
            return srcvalue >= tagvalue;
            break;
        case TAG_I_LT:
        {
            auto srcint = atoll(srcvalue.c_str());
            auto tagint = atoll(tagvalue.c_str());
            if (srcint == 0 || tagint == 0) {
                return false;
            }
            return srcint < tagint;
            break;
        }
        case TAG_I_GT:
        {
            auto srcint = atoll(srcvalue.c_str());
            auto tagint = atoll(tagvalue.c_str());
            if (srcint == 0 || tagint == 0) {
                return false;
            }
            return srcint < tagint;
            break;
        }
        case TAG_I_GE:
        {
            auto srcint = atoll(srcvalue.c_str());
            auto tagint = atoll(tagvalue.c_str());
            if (srcint == 0 || tagint == 0) {
                return false;
            }
            return srcint >= tagint;
            break;
        }
        case TAG_I_LE:
        {
            auto srcint = atoll(srcvalue.c_str());
            auto tagint = atoll(tagvalue.c_str());
            if (srcint == 0 || tagint == 0) {
                return false;
            }
            return srcint <= tagint;
            break;
        }
        case TAG_V_LT:
            return pkgVersionCmp(srcvalue, tagvalue) < 0;
            break;
        case TAG_V_LE:
            return pkgVersionCmp(srcvalue, tagvalue) <= 0;
            break;
        case TAG_V_GT:
            return pkgVersionCmp(srcvalue, tagvalue) > 0;
            break;
        case TAG_V_GE:
            return pkgVersionCmp(srcvalue, tagvalue) >= 0;
            break;
        default:
            return false;
            break;
    }
}

#pragma mark -

TagFile::TagFile(const std::string& filename, bool zfile):m_cur(0) {
    open(filename, zfile);
}

TagFile::~TagFile() {
    
}

bool TagFile::open(const std::string& filename, bool zfile) {
    if (!filename.empty()) {
        std::ifstream fstream(filename);
        std::istream* stream = nullptr;
        zlib_stream::zip_istream zstream(fstream);
        if (zfile) {
            stream = &zstream;
        } else {
            stream = &fstream;
        }
        if (!fstream.is_open()) {
            std::cerr << "Failed to open file for parsing: '" << filename << "'" << std::endl;
            return false;
        }
        m_sections.clear();
        parseSections(*stream);
    }
    return true;
}

const TagSection& TagFile::section() const {
    return m_sections.at(m_cur);
}

size_t TagFile::sectionCount() const {
    return m_sections.size();
}

bool TagFile::nextSection() {
    if (m_cur >= m_sections.size() - 1) {
        return false;
    }
    m_cur++;
    return true;
}

void TagFile::rewind() {
    m_cur = 0;
}

bool TagFile::tag(const std::string& tagname, std::string& out_tagvalue) {
    return section().tag(tagname, out_tagvalue);
}

void TagFile::parseSections(std::istream& stream) {
    TagParser parser(stream);
    TagSection sec;
    while (parser.nextSection(sec)) {
        m_sections.push_back(sec);
    }
}

std::vector<TagSection> TagFile::filter(const FilterConditions& conds) {
    std::vector<TagSection> results;
    TagSection* prevSection = nullptr;
    for(const auto& section: m_sections){
        bool match = false;
        for(const auto& cond: conds) {
            if (cond.matchSection(section)) {
                match = true;
                break;
            }
        }
        if (match) {
            TagSection sec(section);
            if (prevSection == nullptr) {
                prevSection = &sec;
            } else {
                prevSection->setNext(&sec);
            }
            results.push_back(sec);
        }
    }
    return results;
}

#pragma mark -

Version::Version(const TagSection& ctrlFile): m_section(ctrlFile) {
    // Build dep list
    m_depList = std::move(parseDepString(depString()));
    // Get deb file path
    std::string debFilePath;
    if(m_section.tag("debpath", debFilePath)) {
        m_debFilePath = debFilePath;
    }
    
    m_status = parseStatusString(statusStr());
}

Version::Version(const Version& other) {
    m_depList = other.m_depList;
    m_debFilePath = other.m_debFilePath;
    m_section = other.m_section;
    m_status = other.m_status;
}

Version::~Version() {
    
}

uint64_t Version::itemID() const {
    std::string id;
    if(m_section.tag("itemid", id)) {
        return strtoull(id.c_str(), nullptr, 10);
    }
    return 0;
}

bool Version::checkDep(const PackageDepTuple& dep) const {
    //std::cout << packageName() << std::endl;
    if (std::get<0>(dep) != packageName()) {
        return false;
    }
    
    switch (std::get<1>(dep)) {
        case VER_EQ:
            return pkgVersionCmp(version(), std::get<2>(dep)) == 0;
            
        case VER_GE:
            return pkgVersionCmp(version(), std::get<2>(dep)) >= 0;
            
        case VER_GT:
            return pkgVersionCmp(version(), std::get<2>(dep)) > 0;
            
        case VER_LE:
            return pkgVersionCmp(version(), std::get<2>(dep)) <= 0;
            
        case VER_LT:
            return pkgVersionCmp(version(), std::get<2>(dep)) < 0;
            
        case VER_ANY:
            return true;
            
        default:
            break;
    }
    return false;
}

std::string Version::packageName() const {
    std::string name;
    if (m_section.tag("package", name)) {
        std::transform(name.begin(), name.end(), name.begin(), ::tolower);
        return name;
    }
    return "";
}

std::string Version::depString() const {
    std::string dep;
    if (m_section.tag("depends", dep)) {
        return dep;
    }
    return "";
}

std::string Version::statusStr() const {
    std::string status;
    if(m_section.tag("status", status)) {
        return status;
    }
    return "";
}

void Version::setStatusStr(const std::string& sts) {
    m_status = parseStatusString(sts);
}

PackageStatus Version::parseStatusString(const std::string& str) const {
    if(str.empty()) {
        return std::make_tuple(MK_UNKNOWN, "", ST_UNKNOWN);
    }
    std::istringstream stream(str);
    std::string mark_s, ok, state_s;
    stream >> mark_s >> ok >> state_s;
    
    PackageMark mark;
    if(mark_s == "unknown") {
        mark = MK_UNKNOWN;
    } else if (mark_s == "install") {
        mark = MK_INSTALL;
    } else if (mark_s == "remove" || mark_s == "deinsall") {
        mark = MK_REMOVE;
    } else if (mark_s == "purge") {
        mark = MK_PURGE;
    } else if (mark_s == "hold") {
        mark = MK_HOLD;
    } else {
        mark = MK_UNKNOWN;
    }
    
    PackageState state;
    if(state_s == "not-installed") {
        state = ST_NOT_INSTALLED;
    } else if(state_s == "installed") {
        state = ST_INSTALLED;
    } else if(state_s == "config-files") {
        state = ST_CONFIGS;
    } else if(state_s == "unpacked") {
        state = ST_UNPACKED;
    } else if(state_s == "half-configured") {
        state = ST_HALF_CFG;
    } else if(state_s == "half-installed") {
        state = ST_HALF_INST;
    } else if(state_s == "triggers-awaited") {
        state = ST_WAIT;
    } else if(state_s == "triggers-pending") {
        state = ST_PEND;
    } else {
        state = ST_UNKNOWN;
    }
    
    return std::make_tuple(mark, "ok", state);
}

PackageStatus Version::status() const {
    return m_status;
}

PackageMark Version::mark() const {
    return std::get<0>(status());
}

PackageState Version::state() const {
    return std::get<2>(status());
}

bool Version::isInstalled() const {
    return state() == ST_INSTALLED;
}

std::string Version::version() const {
    std::string ver;
    if (m_section.tag("version", ver)) {
        return ver;
    }
    return "";
}

bool Version::operator<(const Version& version) const {
    return pkgVersionCmp(this->version(), version.version()) < 0;
}

bool Version::operator>(const Version& version) const {
    return pkgVersionCmp(this->version(), version.version()) > 0;
}

bool Version::operator<=(const Version& version) const {
    return pkgVersionCmp(this->version(), version.version()) <= 0;
}

bool Version::operator>=(const Version& version) const {
    return pkgVersionCmp(this->version(), version.version()) >= 0;
}

bool Version::operator==(const Version& version) const {
    return pkgVersionCmp(this->version(), version.version()) == 0;
}

std::string Version::sha1Checksum() const {
    std::string sha1;
    if (m_section.tag("sha1", sha1)) {
        return sha1;
    }
    return "";
}

std::string Version::md5Checksum() const {
    std::string md5;
    if (m_section.tag("md5", md5)) {
        return md5;
    }
    return "";
}

std::string Version::sha256Checksum() const {
    std::string sha256;
    if (m_section.tag("sha256", sha256)) {
        return sha256;
    }
    return "";
}

const std::vector<std::vector<PackageDepTuple>>& Version::dep_list() const {
    return m_depList;
}

const std::string& Version::debFilePath() const {
    return m_debFilePath;
}

void Version::setDebFilePath(const std::string& path) {
    m_debFilePath = path;
}

#pragma mark -

Package::Package():m_curVersion(nullptr) {
    
}

Package::Package(const std::string& pkgName, TagFile& ctrlFile)
:m_pkgName(pkgName), m_curVersion(nullptr) {
    initWithTagFile(pkgName, ctrlFile);
}

Package::Package(const std::string& pkgName, const std::vector<TagSection>& sections)
:m_pkgName(pkgName), m_curVersion(nullptr) {
    initWithSections(sections);
}

Package::Package(const std::string& pkgName)
:m_pkgName(pkgName), m_curVersion(nullptr) {
    
}

Package& Package::operator=(const Package& other) {
    m_pkgName = other.m_pkgName;
    m_versions = other.m_versions;
    m_curVersion = other.m_curVersion;
    return *this;
}

Package& Package::operator=(const Package&& other) {
    m_pkgName = std::move(other.m_pkgName);
    m_versions = std::move(other.m_versions);
    m_curVersion = other.m_curVersion;
    return *this;
}

Package::Package(const Package& other) {
    m_pkgName = other.m_pkgName;
    m_versions = other.m_versions;
    m_curVersion = other.m_curVersion;
}

Package::Package(const Package&& other) {
    m_pkgName = std::move(other.m_pkgName);
    m_versions = std::move(other.m_versions);
    m_curVersion = other.m_curVersion;
}

void Package::initWithTagFile(const std::string& pkgName, TagFile& ctrlFile) {
    FilterCondition nameFilter(std::make_pair("package", pkgName), FilterCondition::TAG_EQ);
    auto sections = std::move(ctrlFile.filter(FilterConditions({nameFilter})));
    initWithSections(sections);
}

void Package::initWithSections(const std::vector<TagSection>& sections) {
    for (const auto& sec: sections) {
        Version ver(sec);
        m_versions.insert(std::make_pair(ver.version(), std::move(ver)));
        if (ver.isInstalled()) {
            setCurVersion(ver.version());
        }
    }
}

Package::~Package() {
    
}

const std::string& Package::name() const {
    return m_pkgName;
}

size_t Package::versionCount() const {
    return m_versions.size();
}

const Version* Package::curVersion() const {
    return m_curVersion;
}

void Package::setCurVersion(const std::string verStr) {
    auto ver = version(verStr);
    if (ver) {
        m_curVersion = ver;
    }
}

const Version* Package::version(const std::string& ver) const {
    auto v = m_versions.find(ver);
    if (v == m_versions.end()) {
        return nullptr;
    }
    return &m_versions.at(ver);
}

const std::vector<const Version*> Package::ver_list() const {
    std::vector<const Version*> versions;
    for(const auto& ver: m_versions) {
        versions.push_back(&ver.second);
    }
    return versions;
}

void Package::addVersion(const Version& version) {
    m_versions.insert(std::make_pair(version.version(), std::move(version)));
    if (version.isInstalled()) {
        setCurVersion(version.version());
    }
}

void Package::updateVersionStatusStr(const std::string& verStr, const std::string& status) {
    auto itVer = m_versions.find(verStr);
    if (itVer != m_versions.end()) {
        itVer->second.setStatusStr(status);
    }
}

const Version* Package::checkDep(const PackageDepTuple& dep) const {
    if(std::get<0>(dep) != name()) {
        return nullptr;
    }
    if (ver_list().empty()) {
        return nullptr;
    }
    
    for(auto ver:m_versions) {
        if (ver.second.checkDep(dep)) {
            return &m_versions.at(ver.first);
        }
    }
    return nullptr;
}

#pragma mark -

PackageCache::PackageCache(TagFile& cacheFile) {
    initWithTagFile(cacheFile);
}

PackageCache::PackageCache(const std::string& filename) {
    TagFile tagFile(filename);
    initWithTagFile(tagFile);
}

PackageCache::PackageCache() {
    
}

void PackageCache::initWithTagFile(TagFile& cacheFile) {
    cacheFile.rewind();
    if(cacheFile.sectionCount() <= 0) {
        std::cerr << "No sections found in tag file" << std::endl;
        return;
    }
    do {
        auto sec = cacheFile.section();
        std::string pkgName;
        sec.tag("package", pkgName);
        std::transform(pkgName.begin(), pkgName.end(), pkgName.begin(), ::tolower);
        if (m_packages.find(pkgName) == m_packages.end()) {
            Package pkg(pkgName);
            m_packages[pkgName] = std::move(pkg);
        }
        Version ver(sec);
        m_packages[pkgName].addVersion(std::move(sec));
    } while(cacheFile.nextSection());
}

void PackageCache::markInstalled(TagFile& tagFile) {
    tagFile.rewind();
    if(tagFile.sectionCount() <= 0){
        // Empty file
        return;
    }
    // Mark installed packages
    do {
        auto sec = tagFile.section();
        std::string pkgName;
        sec.tag("package", pkgName);
        std::transform(pkgName.begin(), pkgName.end(), pkgName.begin(), ::tolower);
        auto pkg = m_packages.find(pkgName);
        if (pkg != m_packages.end()) {
            std::string verStr;
            sec.tag("version", verStr);
            std::string status;
            sec.tag("status", status);
            pkg->second.setCurVersion(verStr);
            pkg->second.updateVersionStatusStr(verStr, status);
        }
    } while(tagFile.nextSection());
}

void PackageCache::markInstalled(const std::string& tagFileName) {
    TagFile tagFile(tagFileName);
    markInstalled(tagFile);
}

PackageCache::~PackageCache() {

}

void PackageCache::addPackage(const Package& package) {
    m_packages.insert(std::make_pair(package.name(), std::move(package)));
}

bool PackageCache::checkDep(const PackageDepTuple& dep) const {
    for(const auto& pkg: m_packages) {
        if(pkg.second.checkDep(dep)){
            return true;
        }
    }
    return false;
}

const std::map<std::string, Package>& PackageCache::allPackages() const {
    return m_packages;
}

const Package* PackageCache::package(const std::string& pkgName) const {
    auto pkg = m_packages.find(pkgName);
    if (pkg != m_packages.end()) {
        return &(pkg->second);
    }
    return nullptr;
}

const Version* PackageCache::version(const std::string& pkgName, const std::string& ver) const {
    auto pkg = m_packages.find(pkgName);
    if (pkg == m_packages.end()) {
        return nullptr;
    }
    auto v = pkg->second.version(ver);
    return v;
}

const Version* PackageCache::findFirstVersionOfDeps(const std::vector<PackageDepTuple>& deps) const {
    const Version* ver = nullptr;
    std::find_first_of(m_packages.begin(),
                       m_packages.end(),
                       deps.begin(),
                       deps.end(),
                       [&ver](const std::pair<std::string, Package>& pkg, const PackageDepTuple& dep){
                           auto v = pkg.second.checkDep(dep);
                           if(v){
                               ver = v;
                               return true;
                           }
                           return false;
                       });
    return ver;       
}

#pragma mark -

DependencySolver::Step::Step(const Package* curPackage, const PackageDepTuple& targetDep, Step* parent, const Version* srcVersion, int targetVersionIndex)
:curPackage(curPackage),
 srcVersion(srcVersion),
 parent(parent),
 curVerIndex(targetVersionIndex),
 level(0),
 fulfilled(false),
 skip(false),
 targetDep(targetDep)
{
    assert(curPackage);
    
    // Get all possible versions
    for(auto& ver:curPackage->ver_list()) {
        if (ver->checkDep(targetDep)) {
            versions.push_back(ver);
        }
    }
}

DependencySolver::Step::Step(Step && other)
:curPackage(other.curPackage),
 srcVersion(other.srcVersion),
 parent(other.parent),
 curVerIndex(other.curVerIndex),
 level(other.level),
 fulfilled(other.fulfilled),
 skip(other.skip),
 targetDep(other.targetDep),
 children(std::move(other.children)),
 versions(std::move(other.versions))
{
    other.curPackage = nullptr;
    other.srcVersion = nullptr;
    other.parent = nullptr;
    other.curVerIndex = 0;
    other.level = 0;
    other.fulfilled = false;
    other.skip = false;
}

DependencySolver::Step::Step(const Step& other) {
    // A Step should not be copied at anytime
}

DependencySolver::Step::Step()
:curPackage(nullptr),
 srcVersion(nullptr),
 parent(nullptr),
 curVerIndex(0),
 level(0),
 fulfilled(false),
 skip(false),
 targetDep()
{
}

const Version* DependencySolver::Step::targetVersion() const {
    assert(curVerIndex >= 0);
    return versions[curVerIndex];
}

DependencySolver::Step& DependencySolver::Step::operator=(DependencySolver::Step&& other) {
    curPackage = other.curPackage;
    srcVersion = other.srcVersion;
    parent = other.parent;
    curVerIndex = other.curVerIndex;
    level = other.level;
    fulfilled = other.fulfilled;
    skip = other.skip;
    targetDep = other.targetDep;
    versions = std::move(other.versions);
    children = std::move(other.children);
    
    other.curPackage = nullptr;
    other.srcVersion = nullptr;
    other.parent = nullptr;
    other.curVerIndex = 0;
    other.level = 0;
    other.fulfilled = false;
    other.skip = false;
    return *this;
}

DependencySolver::Step& DependencySolver::Step::operator=(const Step& other) {
    return *this;
}

#pragma mark -

DependencySolver::DependencySolver(const std::string& indexFile, const std::string& controlFile,
                                   const DepVector& unresolvedDeps)
:m_unresolvedDeps(unresolvedDeps)
{
    // Init index
    initIndex(indexFile, controlFile);
    // Init reverse dependencies map
    initRevDepMap();
}

DependencySolver::DependencySolver(const std::string& indexFile, const std::string& controlFile)
{
    // Init index
    initIndex(indexFile, controlFile);
    // Init reverse dependencies map
    initRevDepMap();
}

void DependencySolver::initIndex(const std::string& indexFile, const std::string& controlFile) {
    TagFile cache(controlFile, false); // dpkg cache file is not compressed
    TagFile index(indexFile);
    m_index.initWithTagFile(index);
    m_cache.initWithTagFile(cache);
    m_index.markInstalled(cache);
}

void DependencySolver::initUnresolvedDeps(const DepVector& unresolvedDeps) {
    if (unresolvedDeps.empty()) {
        return;
    }

    m_unresolvedDeps = unresolvedDeps;
}

DependencySolver::RevDepMapEntry DependencySolver::make_revDepEntry(const std::string& targetPkgName, const Version* srcVersion, const PackageDepTuple& targetDep)
{
    return std::make_pair(targetPkgName, std::make_pair(srcVersion, targetDep));
}

void DependencySolver::initRevDepMap() {
    // Insert reverse dependency entries into the hashtable
    auto pkgMap = m_index.allPackages();
    for(auto pkg: pkgMap) {
        auto ver = pkg.second.curVersion();
        // Skip not installed packages, because we only check conflicts on installed packages
        if(!ver) continue;
        
        auto depList = ver->dep_list();
        for(auto& depChoiceList: depList) {
            // Check each dependency and add installed dependencies as reverse dependencies
            for(auto& dep:depChoiceList) {
                // Get dependency package
                auto targetPkg = m_index.package(depTuplePackageName(dep));
                // Check if the dependency is installed, if it is, add an entry to the reverse dependency table
                if(targetPkg && targetPkg->curVersion()){
                    auto revDepEntry = make_revDepEntry(targetPkg->name(), ver, dep);
                    m_cacheRevDepMap.insert(std::move(revDepEntry));
                }
            } // for dep
        } // for depChoiceList
    }// for pkg
}

// Check if the step breaks the current installation
// Returns a list of broken dependencies
std::vector<std::pair<const Version*, PackageDepTuple>> DependencySolver::checkConflicts(const Version* targetVersion) {
    auto targetPkgName = targetVersion->packageName();
    std::vector<std::pair<const Version*, PackageDepTuple>> brokenVers;
    // Check whether it breaks the current installation
    auto revDep = m_cacheRevDepMap.find(targetPkgName);
    if (revDep == m_cacheRevDepMap.end()) {
        // No reverse dependencies
        return brokenVers;
    }
    auto revDepRange = m_cacheRevDepMap.equal_range(targetPkgName);
    for (auto rev = revDepRange.first; rev != revDepRange.second; ++rev) {
        // Check each reverse dependency to see if the step staisfies the dependency
        auto requiredDep = rev->second.second;
        if (!targetVersion->checkDep(requiredDep)) {
            brokenVers.push_back(std::make_pair(rev->second.first, requiredDep));
        }
    }
    return brokenVers;
}

DependencySolver::StepPtrRef DependencySolver::newStep(const Package* curPackage, const PackageDepTuple& targetDep, Step* parent, const Version* srcVer) {
    
    if(m_steps.find(curPackage->name()) != m_steps.end()) {
        return m_steps[curPackage->name()];
    }
    
    StepPtr step(new Step(curPackage, targetDep, parent, srcVer));
    
    // Add current step as a child to parent's children list
    if (parent) {
        step->srcVersion = parent->srcVersion;
        step->level = parent->level + 1;
        m_steps[curPackage->name()] = std::move(step);
        parent->children.push_back(step.get());
    } else {
        m_steps.insert(std::move(std::make_pair(curPackage->name(), std::move(step))));
    }
    return m_steps[curPackage->name()];
}

bool DependencySolver::resolveSingleDep(Step* step) {
    auto targetPkgName = step->curPackage->name();
    auto iter = m_visited.find(targetPkgName);
    // Mark visited
    if (iter == m_visited.end()) {
        m_visited.insert(targetPkgName);
    } else {
        return true;
    }
    // Check if the target version will break anything
    auto installed = step->curPackage;
    if (installed && installed->curVersion() && installed->curVersion()->isInstalled()) {
        // Check if it will break the original installation
        auto vers = checkConflicts(step->targetVersion());
        if (!vers.empty()) {
            // Add broken packages to steps queue and m_unresolvedDeps
            for(auto ver:vers) {
                auto pkg = m_index.package(ver.first->packageName());
                if(!pkg) {
                    std::cerr << "Fatal: package " << ver.first->packageName() <<
                    " cannot be found in the package index." << std::endl;
                    exit(1);
                }
                Step* nstep;
                auto iterStep = m_steps.find(pkg->name());
                if (iterStep != m_steps.end()) {
                    nstep = iterStep->second.get();
                } else {
                    nstep = newStep(pkg, ver.second, step, step->targetVersion()).get();
                }
                // Reset the set as not fulfilled
                step->fulfilled = false;
                step->skip = false;
                addSuccessors(nstep);
                m_unprocessedSteps.push(nstep);
            }
        } else {
            // Target version is installed
            
            // Check if it's an update
            if(*(step->targetVersion()) > *(installed->curVersion())) {
                step->fulfilled = false;
                step->skip = false;
            } else {
                step->fulfilled = true;
                step->skip = true;
            }
            return true;
        }
    }// if installed
    
    // Check if it's in the index
    // Process dependencies
    for(auto& depList:step->targetVersion()->dep_list()) {
        for(auto& dep:depList) {
            if (m_visited.find(depTuplePackageName(dep)) != m_visited.end()) {
                continue;
            }
            const Package* pkg = nullptr;
            pkg = m_index.package(depTuplePackageName(dep));
            if (!pkg) {
                // Not in the index
                // Dependency dep has to be satisfied in the cache
                pkg = m_cache.package(depTuplePackageName(dep));
                if(!pkg || !pkg->curVersion() || !pkg->curVersion()->checkDep(dep)) {
                    return false;
                } else {
                    continue;
                }
            }
            // Check if the dependency is already installed and the installed version satisfies the dependency
            if (pkg->curVersion() && pkg->curVersion()->checkDep(dep)) {
                continue;
            }
            auto &nstep = newStep(pkg, dep, step, step->targetVersion());
            addSuccessors(nstep.get());
            m_unprocessedSteps.push(nstep.get());
        }
    }
    return true;
}

void DependencySolver::processNextVersion(Step* step) {
    step->curVerIndex += 1;
    addSuccessors(step);
}

void DependencySolver::addSuccessors(Step* step) {
    if (step->curVerIndex >= step->versions.size()) {
        std::cerr << "All versions of " << step->curPackage->name() << " were checked." << std::endl;
        return;
    }
    
    // Clean children, because we are processing a new target version
    step->children.clear();
    for (auto &depList:step->targetVersion()->dep_list()){
        for(auto &dep: depList) {
            auto pkg = m_index.package(depTuplePackageName(dep));
            if (!pkg) {
                // Dependency is not in the index, check local cache
                pkg = m_cache.package(depTuplePackageName(dep));
                if(!pkg || !pkg->curVersion() || !pkg->curVersion()->checkDep(dep)) {
                    m_brokenDeps.push_back(dep);
                    break;
                }
                continue;
            }
            Step *nstep = nullptr;
            auto iterStep = m_steps.find(pkg->name());
            if (iterStep == m_steps.end()) {
                nstep = newStep(pkg, dep, step, step->targetVersion()).get();
            } else {
                nstep = iterStep->second.get();
            }
            m_unprocessedSteps.push(nstep);
        }
    }
}

void DependencySolver::processSteps() {
    while (!m_unprocessedSteps.empty()) {
        auto step = m_unprocessedSteps.front();
        if(!resolveSingleDep(step)) {
            // Check reasons
            if (step->curVerIndex < step->versions.size()) {
                // Try next version
                processNextVersion(step);
                continue;
            }
            if (step->level >= MaxDependencyResolveDepth) {
                std::cerr << "Max steps(" << MaxDependencyResolveDepth
                          << ") reached, cannot go further, sorry." << std::endl;
                break;
            }
            // No reasons found, or it can't be fixed, consider it as broken
            m_brokenDeps.push_back(step->targetDep);
            break;
        }
        m_unprocessedSteps.pop();
    }
}

void DependencySolver::clearContainers() {
    // For some containers, clear() method won't release the space
    m_steps.clear();
    m_visited.clear();
    m_unprocessedSteps = std::move(std::queue<Step*>());
    m_resolvedDeps = std::move(std::vector<const Version*>());
}

bool DependencySolver::calcDep(std::vector<const Version*>& out_targetDeps, DepVector& out_brokenDeps) {
    if (m_unresolvedDeps.empty()) {
        std::cerr << "No unresolved dependencies, calcDep() does nothing" << std::endl;
        // Nothing to do, the system remains consistant, so the dependencies are all fulfilled.
        return true;
    }
    // NOTE: Users need to call initUnresolvedDeps() before calling this method
    // Clear previous result for a new start
    clearContainers();
    // Add steps for unresolved dependencies
    auto dep = m_unresolvedDeps.begin();
    while(dep != m_unresolvedDeps.end()) {
        auto pkg = m_index.package(depTuplePackageName(*dep));
        if (!pkg) {
            std::cerr << "Unable to find package '" << depTuplePackageName(*dep) << "'" << std::endl;
            return false;
        }
        StepPtrRef step = newStep(pkg, *dep);
        addSuccessors(step.get());
        m_unprocessedSteps.push(step.get());
        dep = m_unresolvedDeps.erase(dep);
    }
    // Process all unprocessed steps and unresolved dependencies
    processSteps();
    
    // If there are no unresolved dependencies, then we found a solution
    if (m_unprocessedSteps.empty() && m_unresolvedDeps.empty() && m_brokenDeps.empty()) {
        for(auto& step: m_steps) {
            if (!step.second->skip) {
                out_targetDeps.push_back(step.second->targetVersion());
            }
        }
        return true;
    }
    
    if (!m_brokenDeps.empty()) {
        out_brokenDeps.assign(m_brokenDeps.begin(), m_brokenDeps.end());
        std::cerr << "Found broken packages" << std::endl;
        return false;
    }
    
    std::cerr << "Shouldn't happen: non-empty m_unprocessedSteps or m_unresolvedDeps" << std::endl;
    return false;
}

DepVector DependencySolver::getUpdates() const {
    DepVector result;
    for(auto& pkg:m_index.allPackages()) {
        if(!pkg.second.curVersion()) continue;
        
        PackageDepTuple dep = std::make_tuple(pkg.second.name(), VER_GT, pkg.second.curVersion()->version());
        if (m_index.findFirstVersionOfDeps({dep})) {
            result.push_back(std::move(dep));
        }
    }
    return result;
}