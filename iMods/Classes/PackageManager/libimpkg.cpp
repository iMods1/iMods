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
        sstream.get();
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
    nch = sstream.get();
    while (!sstream.eof() && tkPred(nch)) {
        token += nch;
        nch = sstream.get();
    }
    return std::make_pair(tk_type, token);
}

std::vector<std::vector<PackageDepTuple>> parseDepString(const std::string& depString) {
    std::istringstream sstream(depString);
    std::vector<PackageDepTuple> group;
    std::vector<std::vector<PackageDepTuple>> result;
    
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
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                result.push_back(std::move(group));
                group.clear();
                targetPkg.clear();
                targetVer.clear();
                targetOp = VER_ANY;
                break;
            case TK_OR:
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                targetPkg.clear();
                targetVer.clear();
                targetOp = VER_ANY;
                break;
            case TK_EOF:
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
    
    TagParser(std::ifstream& tagfile);
    
    bool nextSection(TagSection& section);

private:
    
    bool nextTag(std::string& tag, std::string& value);
    std::ifstream& m_tagFile;
    size_t m_bufPtr;
};

#pragma mark -

TagParser::TagParser(std::ifstream& tagfile):m_tagFile(tagfile), m_bufPtr(0) {
    
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
        // Count leading spaces
        size_t leadingSpaceCount = 0;
        while (p != linebuf.end() && std::isspace(*p)) {
            leadingSpaceCount++;
            p++;
        }
        // Empty lines(including lines consist of whitespaces) separate sections
        if (leadingSpaceCount == linebuf.length()) {
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
            std::getline(m_tagFile, linebuf);
            p = linebuf.begin();
            continue;
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

TagFile::TagFile(const std::string& filename):m_cur(0) {
    open(filename);
}

TagFile::~TagFile() {
    
}

bool TagFile::open(const std::string& filename) {
    if (!filename.empty()) {
        std::ifstream stream(filename);
        if (!stream.is_open()) {
            std::cerr << "Failed to open file for parsing: '" << filename << "'" << std::endl;
            return false;
        }
        m_sections.clear();
        parseSections(stream);
    }
    return true;
}

const TagSection& TagFile::section() const {
    return m_sections.at(m_cur);
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

void TagFile::parseSections(std::ifstream& stream) {
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
}

Version::Version(const Version& other) {
    m_depList = other.m_depList;
    m_debFilePath = other.m_debFilePath;
    m_section = other.m_section;
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
    std::cout << packageName() << std::endl;
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

std::string Version::version() const {
    std::string ver;
    if (m_section.tag("version", ver)) {
        return ver;
    }
    return "";
}

bool Version::operator<(const Version& version) {
    return pkgVersionCmp(this->version(), version.version()) < 0;
}

bool Version::operator>(const Version& version) {
    return pkgVersionCmp(this->version(), version.version()) > 0;
}

bool Version::operator<=(const Version& version) {
    return pkgVersionCmp(this->version(), version.version()) <= 0;
}

bool Version::operator>=(const Version& version) {
    return pkgVersionCmp(this->version(), version.version()) >= 0;
}

bool Version::operator==(const Version& version) {
    return pkgVersionCmp(this->version(), version.version()) == 0;
}

std::ostream& Version::operator<<(std::ostream& out) {
    out << packageName() << " " << version();
    return out;
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

Package::Package(const std::string& pkgName, TagFile& ctrlFile, bool installed)
:m_pkgName(pkgName), m_curVersion(nullptr) {
    initWithTagFile(pkgName, ctrlFile, installed);
}

Package::Package(const std::string& pkgName, const std::vector<TagSection>& sections, bool installed)
:m_pkgName(pkgName), m_curVersion(nullptr) {
    initWithSections(sections, installed);
}

Package::Package(const std::string& pkgName, bool installed)
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

void Package::initWithTagFile(const std::string& pkgName, TagFile& ctrlFile, bool installed) {
    FilterCondition nameFilter(std::make_pair("package", pkgName), FilterCondition::TAG_EQ);
    auto sections = std::move(ctrlFile.filter(FilterConditions({nameFilter})));
    initWithSections(sections, installed);
}

void Package::initWithSections(const std::vector<TagSection>& sections, bool installed) {
    for (const auto& sec: sections) {
        Version ver(sec);
        m_versions.insert(std::make_pair(ver.version(), std::move(ver)));
    }
    
    // If this is an installed package, there should be only one version installed
    if (installed) {
        assert(m_versions.size() == 1);
        m_curVersion = &(m_versions.begin()->second);
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

const std::vector<const Version*> Package::ver_list() const {
    std::vector<const Version*> versions;
    for(const auto& ver: m_versions) {
        versions.push_back(&ver.second);
    }
    return versions;
}

void Package::addVersion(const Version& version) {
    m_versions.insert(std::make_pair(version.version(), std::move(version)));
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

void PackageCache::initWithTagFile(TagFile& cacheFile) {
    do {
        auto sec = cacheFile.section();
        std::string pkgName;
        sec.tag("package", pkgName);
        if (m_packages.find(pkgName) == m_packages.end()) {
            Package pkg(pkgName);
            m_packages[pkgName] = std::move(pkg);
        }
        Version ver(sec);
        m_packages[pkgName].addVersion(std::move(sec));
    } while(cacheFile.nextSection());
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

DependencySolver::Step::Step(const Version* srcVersion, const PackageDepTuple& targetDep, Step* parent)
:srcVersion(srcVersion), targetDep(targetDep), parent(parent)
{
    if (parent) {
        parent->children.push_back(this);
    }
}

DependencySolver::Step::Step()
:srcVersion(nullptr), parent(nullptr)
{
}

DependencySolver::DependencySolver(const PackageCache& cache, const PackageIndex& index,
                                   const DepVector& unresolvedDeps)
:m_cache(cache), m_index(index), m_unresolvedDeps(unresolvedDeps)
{
    // Init reverse dependencies map
    initRevDepMap();
}

DependencySolver::DependencySolver(const PackageCache& cache, const PackageIndex& index)
:m_cache(cache), m_index(index)
{
    // Init reverse dependencies map
    initRevDepMap();
}

void DependencySolver::initUnresolvedDeps(const DepVector& unresolvedDeps) {
    if (!unresolvedDeps.empty()) {
        return;
    }

    m_unresolvedDeps = unresolvedDeps;
}

void DependencySolver::initRevDepMap() {
    // Insert reverse dependency entries into the hashtable
    auto pkgMap = m_cache.allPackages();
    for(auto pkg: pkgMap) {
        auto ver = pkg.second.curVersion();
        auto depList = ver->dep_list();
        for(auto& depChoiceList: depList) {
            for(auto& dep:depChoiceList) {
                auto targetPkg = m_cache.package(depTuplePackageName(dep));
                if(targetPkg){
                    auto revDepEntry = std::make_pair(targetPkg, std::make_pair(ver, dep));
                    m_cacheRevDepMap.insert(revDepEntry);
                }
            } // for dep
        } // for depChoiceList
    }// for pkg
}

bool DependencySolver::checkConflicts(const Step& step) {
    auto targetPkgName = depTuplePackageName(step.targetDep);
    // Check whether it breaks the current installation
    auto revDep = m_cacheRevDepMap.find(targetPkgName);
}

DependencySolver::Step& DependencySolver::newStep(const Version* ver, const PackageDepTuple& dep, Step* parent) {
    Step step(ver, dep, parent);
    step.level = m_steps.size() + 1;
    m_steps[depTuplePackageName(dep)] = std::move(step);
    return m_steps[ver->packageName()];
}

bool DependencySolver::resolveSingleDep(Step& step) {
    auto targetPkgName = depTuplePackageName(step.targetDep);
    auto targetPkgVer = depTupleVersion(step.targetDep);
    auto iter = m_visited.find(targetPkgName);
    // Check if visited
    if (iter == m_visited.end()) {
        m_visited.insert(targetPkgName);
    }
    
    // Check if installed
    auto installed = m_cache.package(targetPkgName);
    if (installed) {
        // It's installed, then check if it is an upgrade or downgrade
        if (depTupleVersionOp(step.targetDep) == VER_ANY) {
            // The dependency doesn't have version restrictions, so it's satisfied.
            return true;
        }
        auto installedVer = installed->curVersion()->version();
        auto verCmp = pkgVersionCmp(installedVer, targetPkgVer);
        if (verCmp > 0) {
            std::cerr << step.srcVersion << " requires " << step.targetDep
            << " but version " << installedVer << " is already installed" << std::endl;
            std::cerr << "Cannot downgrade." << std::endl;
            return false;
        }
        else if(verCmp < 0) {
            // It's an upgrade, move alone(treat it as a new package
        } else {
            // The same version installed, return
            return true;
        }
    }
    
    // Get the latest target version that satisfies the dependency
    auto ver = m_index.findFirstVersionOfDeps({step.targetDep});
    if (!ver) {
        m_brokenDeps.push_back(step.targetDep);
        return false;
    }

    // Get the target package
    auto pkg = m_index.package(ver->packageName());
    std::vector<const Version*> verList(pkg->ver_list());
    
    // Check dependencies
    for(auto tarDeps: ver->dep_list()) {
        //dep_list() returns a list of list
        // The inner list is an "OR" list, e.g. "iptools | ipconfig"
        // Just need to choose one of them.
        // The outter list is an "AND" list, e.g. "coreutils, debianutils, dpkg"
        // All of them need to be satisfied.
        
        // TODO: Make a better algorithm to choose a version from tarDeps
        // Currently, we only use the first dependency
        assert(tarDeps.size() > 0);
        auto dep = tarDeps[0];
        // Create a step for it
        auto nstep = newStep(ver, dep, &step);
    }
    
    return false;
}

bool DependencySolver::calcDep(DepVector& out_targetDeps, DepVector& out_brokenDeps) {
    return false;
}