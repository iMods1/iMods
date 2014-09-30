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
    PackageVersionOp targetOp;
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
                targetOp = PackageVersionOp(-1);
                break;
            case TK_OR:
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                targetPkg.clear();
                targetVer.clear();
                targetOp = PackageVersionOp(-1);
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

bool resolveDep(const Package& pkg,
                std::map<std::string, const Package*>& mark,
                PackageCache& cache,
                PackageCache& index,
                std::vector<const Package*>& res) {
    
    mark[pkg.name()] = &pkg;
    
    std::vector<const Version*> verList(pkg.ver_list());
    
    // Return if there are no actual package files
    if (verList.empty()) {
        std::cerr << "Package '" << pkg.name() << "' has no deb files" << std::endl;
        return false;
    }
    
    // FIXME: Move sorting to Package class
    // Sort versions in reverse order, later versions come first
    std::sort(verList.begin(), verList.end(), [](const Version* v1, const Version* v2){
        return pkgVersionCmp(v1->version(), v2->version());
    });
    // Try the latest version first
    bool fulfilled = true;
    for(auto& depTuples:verList[0]->dep_list()) {
        if (depTuples.empty()) {
            // Shouldn't happen
            std::cerr << "Empty dependency tuple list found, this shouldn't happen, it's possibly a bug." << std::endl;
            continue;
        }
        // Remove all dependencies that are already installed.
        std::vector<PackageDepTuple> notInstalledDeps;
        for (const auto& dep: depTuples){
            auto ninstPkg = cache.package(std::get<0>(dep));
            if (!ninstPkg) {
                notInstalledDeps.push_back(dep);
            }
        }
        // notInstalledDeps contain a list of choices of packages, pick the first one in the index
        const Package* depPkg = index.findFirstOfDeps(notInstalledDeps);
        if (depPkg != nullptr) {
            fulfilled = false;
            std::cerr << "Dependencies of " << pkg.name() << "' cannot be resolved";
            break;
        }
        fulfilled &= resolveDep(*depPkg, mark, cache, index, res);
    }
    
    if (fulfilled) {
        res.push_back(&pkg);
        return true;
    } else if(verList.size() == 1){
        // Tried last version, so the dependency cannot be resolved.
        std::cerr << "Cannot resolve dependencies of package '" << pkg.name() << "'" << std::endl;
    } else {
        // #FIXME: Try other versions
        //std::cout << "Trying other versions of package '" << pkg.name() << "'" << std::endl;
    }
    return false;
}

bool calcDep(PackageCache& localCache, PackageCache& remoteIndex,
             const std::vector<const Package*>& targetPackages,
             std::vector<const Package*>& out_toInstallPackages)
{
    std::map<std::string, const Package*> mark;
    std::vector<const Package*> resolved;
    for(auto& pkg: targetPackages) {
        if (localCache.package(pkg->name())) {
            // Package already installed
            mark.insert(std::make_pair(pkg->name(), pkg));
            continue;
        }
        if(!resolveDep(*pkg, mark, localCache, remoteIndex, resolved)){
            return false;
        }
    }
    out_toInstallPackages = std::move(resolved);
    return true;
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
            break;
            
        case VER_GE:
            return pkgVersionCmp(version(), std::get<2>(dep)) >= 0;
            break;
            
        case VER_GT:
            return pkgVersionCmp(version(), std::get<2>(dep)) > 0;
            break;
            
        case VER_LE:
            return pkgVersionCmp(version(), std::get<2>(dep)) <= 0;
            break;
            
        case VER_LT:
            return pkgVersionCmp(version(), std::get<2>(dep)) < 0;
            break;
            
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

Package::Package() {
    
}

Package::Package(const std::string& pkgName, TagFile& ctrlFile):m_pkgName(pkgName) {
    initWithTagFile(pkgName, ctrlFile);
}

Package::Package(const std::string& pkgName, const std::vector<TagSection>& sections):m_pkgName(pkgName) {
    initWithSections(sections);
}

Package::Package(const std::string& pkgName):m_pkgName(pkgName) {
    
}

Package& Package::operator=(const Package& other) {
    m_pkgName = other.m_pkgName;
    m_selectedVersions = other.m_selectedVersions;
    m_versions = other.m_versions;
    return *this;
}

Package& Package::operator=(const Package&& other) {
    m_pkgName = std::move(other.m_pkgName);
    m_selectedVersions = std::move(other.m_selectedVersions);
    m_versions = std::move(other.m_versions);
    return *this;
}

Package::Package(const Package& other) {
    m_pkgName = other.m_pkgName;
    m_selectedVersions = other.m_selectedVersions;
    m_versions = other.m_versions;
}

Package::Package(const Package&& other) {
    m_pkgName = std::move(other.m_pkgName);
    m_selectedVersions = std::move(other.m_selectedVersions);
    m_versions = std::move(other.m_versions);
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

const std::vector<const Version*> Package::ver_list() const {
    std::vector<const Version*> versions;
    for(const auto& ver: m_versions) {
        versions.push_back(&ver.second);
    }
    return versions;
}

void Package::selectVersions(const std::vector<const Version*>& versions) {
    m_selectedVersions = versions;
}

void Package::selectVersions(const std::vector<std::string>& versionStr) {
    m_selectedVersions.clear();
    for(auto& str: versionStr) {
        auto res = m_versions.find(str);
        if (res != m_versions.end()) {
            m_selectedVersions.push_back(&(res->second));
        }
    }
}

const std::vector<const Version*>& Package::selectedVersions() const {
    return m_selectedVersions;
}

void Package::addVersion(const Version& version) {
    m_versions.insert(std::make_pair(version.version(), std::move(version)));
}

bool Package::checkDep(const PackageDepTuple& dep) const {
    if(std::get<0>(dep) != name()) {
        return false;
    }
    if (ver_list().empty()) {
        return false;
    }
    return ver_list()[0]->checkDep(dep);
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

const Package* PackageCache::findFirstOfDeps(const std::vector<PackageDepTuple>& deps) {
    auto pkgIter = std::find_first_of(m_packages.begin(),
                                      m_packages.end(),
                                      deps.begin(),
                                      deps.end(),
                                      [](const std::pair<std::string, Package>& pkg, const PackageDepTuple& dep){
                                          return pkg.second.checkDep(dep);
                                      });
    if (pkgIter != m_packages.end()) {
        return &(pkgIter->second);
    }
    return nullptr;
}
