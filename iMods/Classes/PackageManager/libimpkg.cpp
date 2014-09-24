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
    
    return 999999; // Not possible
}

int pkgVersionCmp(const std::string& v1, const std::string& v2) {
    // Get epoch
    std::string epoch1, epoch2;
    auto epoch_end1 = std::find(v1.begin(), v1.end(), ':');
    auto epoch_end2 = std::find(v2.begin(), v2.end(), ':');
    auto pv1 = v1.begin();
    auto pv2 = v2.begin();
    
    if (epoch_end1 != v1.end()) {
        epoch1 = std::string(pv1, epoch_end1);
        pv1 = epoch_end1 + 1; // Skip the ':'
    }
    
    if(epoch_end2 != v2.end()) {
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
    auto pkgVerEnd1 = v1.begin() + v1.rfind('-');
    
    auto pkgVerEnd2 = v2.begin() + v2.rfind('-');
    
    pkgV1 = std::string(pv1, pkgVerEnd1);
    pkgV2 = std::string(pv2, pkgVerEnd2);
    
    int cmp = pkgVerComponentCmp(pkgV1, pkgV2);
    if (cmp != 0) {
        return cmp;
    }
    
    // Get revision numbers and compare them
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
    TK_EOF
};

typedef std::pair<PackageDepTokenType, std::string> PackageDepToken;


PackageDepToken nextToken(std::istringstream& sstream) {
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
        tk_type = TK_PKG;
        tkPred = isPkgNameChar;
    } else if (isOpChar(nch)) {
        tk_type = TK_OP;
        tkPred = isOpChar;
    } else if (isPkgVerChar(nch)) {
        tk_type = TK_VER;
        tkPred = isPkgVerChar;
    } else if (nch == ',') {
        tk_type = TK_SEP;
        token = nch;
    } else if (nch == '|') {
        tk_type = TK_OR;
        token = nch;
    } else if (nch == '(' || nch == ')') {
        goto parse_begin;
    } else if (nch == '[') {
        // Skip architecture restrictions
        while (!sstream.eof() && nch != ']') {
            nch = sstream.get();
        }
        goto parse_begin;
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
        PackageDepToken token = nextToken(sstream);
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
                result.push_back(group);
                group.clear();
                break;
            case TK_OR:
                group.push_back(std::make_tuple(targetPkg, targetOp, targetVer));
                break;
            case TK_EOF:
                parseDone = true;
                break;
            default:
                break;
        }
    }
    return result;
}

bool checkDep(const std::string& depString, const TagSection& targetPackage) {
    // Parse dependency string
    std::vector<std::vector<PackageDepTuple>> dep_list = std::move(parseDepString(depString));
}

bool calcDep(TagFile& localCache, TagFile& remoteIndex,
             std::vector<TagSection>& targetPackages,
             std::vector<TagSection>& out_toInstallPackages,
             std::vector<TagSection>& out_missingPackages) {
    
}

/* TagParser is used to parse index or status files.
 * It's invoked by TagFile when the file is loaded.
 */
class TagParser {
    
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
        }
    }
    return true;
}

bool TagParser::nextSection(TagSection& tagsection) {
    std::string tagname, tagvalue;
    TagSection section(nullptr);
    while (!m_tagFile.eof() && nextTag(tagname, tagvalue)) {
        section << TagField(tagname, tagvalue);
    }
    if (section.fieldCount() == 0) {
        return false;
    }
    return true;
}

#pragma mark -

TagSection::TagSection(TagSection* next):m_next(next) {

}

TagSection::TagSection(const TagSection& other) {
    m_mapping = other.m_mapping;
    m_next = other.m_next;
}

TagSection::TagSection(const TagSection&& other) {
    m_mapping = std::move(m_mapping);
    m_next = other.m_next;
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
    if (m_mapping.find(tagname) != m_mapping.end()) {
        out_tagvalue = m_mapping.at(tagname);
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
    return m_mapping[tagname];
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

bool FilterCondition::matchTag(const std::string& tagname, const std::string& tagvalue) const{
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
    if (m_cur >= m_sections.size()) {
        return false;
    }
    m_cur++;
    return true;
}

bool TagFile::tag(const std::string& tagname, std::string& out_tagvalue) {
    return section().tag(tagname, out_tagvalue);
}

std::vector<TagSection> TagFile::filter(const FilterConditions& conds) {
    std::vector<TagSection> results;
    TagSection* prevSection = nullptr;
    for(const auto& section: m_sections){
        bool match = true;
        for(const auto& cond: conds) {
            if (cond.matchSection(section)) {
                match = false;
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