public with sharing class TagCloud 
{
    public List<HashtagDefinition> hashTag {get;set;}
    public TagCloud() 
    {
        map<Id,HashtagDefinition> hashTagMap = new map<Id,HashtagDefinition>([SELECT HashtagCount,Id,Name,NameNorm FROM HashtagDefinition ORDER BY HashtagCount DESC LIMIT 10]);
        hashTag = [SELECT HashtagCount,Id,Name,NameNorm FROM HashtagDefinition where Id In : hashTagMap.keySet()];
    }
}