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
#include <map>

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

bool calcDep(PackageCache& localCache, PackageCache& remoteIndex,
             const std::vector<const Package*>& targetPackages,
             std::vector<const Package*>& out_toInstallPackages);

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
    Package(const std::string& pkgName, TagFile& ctrlFile);
    
    Package(const std::string& pkgName, const std::vector<TagSection>& sections);
    
    ~Package();
    
    const std::string& name() const;
    
    const std::vector<const Version*> ver_list() const;
    
    bool checkDep(const PackageDepTuple& dep) const;
    
    // Select a list of versions to install
    // Only one version should be selected before dowload
    void selectVersions(const std::vector<const Version*>& versions);
    
    void selectVersions(const std::vector<std::string>& versionStr);
    
    const std::vector<const Version*>& selectedVersions() const;
    
    void addVersion(const Version& version);
    
private:
    
    void initWithTagFile(const std::string& pkgName, TagFile& ctrlFile);
    
    void initWithSections(const std::vector<TagSection>& sections);
    
    std::string m_pkgName;
    
    std::map<std::string, Version> m_versions;
    
    std::vector<const Version*> m_selectedVersions;
    
};

class Version {
    
public:

    Version(const TagSection& ctrlFile);
    
    ~Version();
    
    uint64_t itemID() const;
    
    // Check whether the version fullfils the dependency
    bool checkDep(const PackageDepTuple& dep) const;
    
    std::string packageName() const;
    
    std::string version() const;
    
    std::string depString () const;

    std::string sha1Checksum() const;
    
    std::string md5Checksum() const;
    
    std::string sha256Checksum() const;
    
    const std::vector<std::vector<PackageDepTuple>>& dep_list() const;
    
    const std::string& debFilePath() const;
    
    void setDebFilePath(const std::string& path);

private:
    
    std::vector<std::vector<PackageDepTuple>> m_depList;
    
    std::string m_debFilePath;
    
    TagSection m_section;
};

class PackageCache {
    
public:
    PackageCache(const TagFile& cacheFile);
    PackageCache(const std::string& filename);
    ~PackageCache();
    
    void addPackage(const Package& package);
    
    bool checkDep(const PackageDepTuple& dep) const;
    
    const Package* package(const std::string& pkgName) const;
    
    const Package* findFirstOfDeps(const std::vector<PackageDepTuple>& deps);
    
    const std::map<std::string, Package>& allPackages() const;
    
private:
    
    PackageCache(const PackageCache&) {}
    PackageCache& operator=(const PackageCache&) { return *this;}
    
    void initWithTagFile(const TagFile& cacheFile);
    
    std::map<std::string, Package> m_packages;
};
#endif /* defined(__iMods__libimpkg__) */
