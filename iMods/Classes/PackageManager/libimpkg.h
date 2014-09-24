//
//  libimpkg.h
//  iMods
//
//  Created by Ryan Feng on 9/20/14.
//  Copyright (c) 2014 Ryan Feng. All rights reserved.
//

#ifndef __iMods__libimpkg__
#define __iMods__libimpkg__

#include <stdio.h>
#include <string>
#include <vector>
#include <unordered_map>
#include <fstream>

typedef std::pair<std::string, std::string> TagField;

class TagSection;
class TagFile;
class FilterCondition;
class Package;
class Version;
class PackageCache;

#pragma mark -

int pkgVersionCmp(const std::string& v1, const std::string& v2);

bool checkDep(const std::string& depString, const TagSection& targetPackage);

bool calcDep(TagFile& localCache, TagFile& remoteIndex,
             std::vector<TagSection>& targetPackages,
             std::vector<TagSection>& out_toInstallPackages,
             std::vector<TagSection>& out_missingPackages);

size_t calcInstalledSize(TagFile& localCache);

size_t calcDownloadSize(TagFile& remoteIndex, const std::vector<TagSection>& toInstallPackages);

#pragma mark -

/* Each TagSection represents a section in an index file.
 * Usually a section is the control information of a package,
 * but it doesn't necessarily to be one.
 */
class TagSection {
    
public:
    TagSection(TagSection* next);
    TagSection(const TagSection& other);
    TagSection(const TagSection&& other);
    
    ~TagSection();
    
    TagSection* next();
    void setNext(TagSection* next);
    
    bool tag(const std::string& tagname, std::string& out_tagvalue) const;
    
    TagSection& operator << (const TagField& field);
    
    const std::string& operator [] (const std::string& tagname);
    
    size_t fieldCount() const;

private:
    
    std::unordered_map<std::string, std::string> m_mapping;
    
    TagSection* m_next;
};

#pragma mark -

class FilterCondition {
    
public:
    
    enum FilterOperator {
        TAG_EQ,
        TAG_NE,
        /* Lexical comparison */
        TAG_A_LT,
        TAG_A_GT,
        TAG_A_LE,
        TAG_A_GE,
        /* Numeric comparison */
        TAG_I_LT,
        TAG_I_GT,
        TAG_I_LE,
        TAG_I_GE,
        /* Version comparison */
        TAG_V_LT,
        TAG_V_GT,
        TAG_V_LE,
        TAG_V_GE,
        /* Date and time comparison */
        // Currently not used
        TAG_D_LT,
        TAG_D_GT,
        TAG_D_LE,
        TAG_D_GE
    };
    
    FilterCondition(const TagField& srcField, FilterOperator op);
    
    virtual ~FilterCondition();
    
    virtual bool matchSection(const TagSection& section) const;
    
    virtual bool matchTag(const std::string& tagname, const std::string& tagvalue) const;
    
private:
    
    const TagField m_srcField;
    
    FilterOperator m_op;
};

typedef std::vector<FilterCondition> FilterConditions;

#pragma mark -

class TagFile {
    
public:
    TagFile(const std::string& filename=std::string());
    
    ~TagFile();
    
    // open a tag file
    bool open(const std::string& filename);
    
    // return current section
    const TagSection& section() const;
    
    // go to next section
    bool nextSection();
    
    // query current section
    bool tag(const std::string& tagname, std::string& out_tagvalue);
    
    // filter all sections and return the ones that meet the conditions
    std::vector<TagSection> filter(const FilterConditions& conds);
    
private:
    void parseSections(std::ifstream& stream);
    std::vector<TagSection> m_sections;
    int m_cur;
};

#pragma mark -

enum PackageVersionOp {
    VER_EQ,
    VER_LT,
    VER_LE,
    VER_GT,
    VER_GE
};

typedef std::tuple<std::string, PackageVersionOp, std::string> PackageDepTuple;

class Package {
    
public:
    Package(TagFile& ctrlFile);
    ~Package(){}
    
    uint64_t itemID() const;
    
    bool checkDep(const Package& pkg);
    
    std::vector<PackageDepTuple> dep_list() const;
    
    std::vector<Version> ver_list() const;
    
};

#endif /* defined(__iMods__libimpkg__) */
