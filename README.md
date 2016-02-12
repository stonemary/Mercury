 
# Project Proposal: Mercury
02.11.2016 preliminary draft

Overview
--------
Inspired by BitTiger’s AppStore project, our project `Mercury` aims to develop an application which crawls movie information from douban.com. 
Our ultimate goal is to create a recommendation service which helps users to find interesting movies and similar users according to their profile. 

Goals
-----
- Complete the project.
- We aim to gain more knowledge on Python and related libraries, data mining  algorithms, and possibly nodeJS.
- Hopefully the project could help us to have a better understanding about operating system and multi-thread.  
- We hope to gain more practice on system design, scalability.

Plan
----
- 02.11 Project Selection, Plan Discussion, and Proposal Draft Writing
- 02.12-02.20 System Design, Resource Discovery
 - kick-off: 02.16.
 - finalization: 02.19.
- 02.20-03.15 Project Implementation

Milestones
----------
- Project Design
- Crawler Basic
 - able to crawl basic information from douban movies
 - random agent
 - random IP (proxy list - cost? - optional?)
- Content Storage
 - Use NoSQL service like MongoDB to store content 
 - Cloud (cost)
- Manager? Queues? Connectors?
- Recommander
 - Preprocessing: read from MongoDB: retrieve data
 - Recommendation: Algorithm implementation
 - Result storage
 - (Visualization)
- Crawler Advanced
 - Concurrency: multi-thread/multi-process
 - Distributed system
 - Configurability (manager?)
 - Able to discover more pages
 - Search Engine Based on Recommander
- Optimization
- Resources
 - [BitTiger Projects](https://bittigerfamily.slack.com/files/qinyuan/F0J4G9QTT/BitTiger_Project_List)

Language & Frameworks
---------------------
- Python2.7 
 - virtualenv
 - pip
 - scrapy, SplashJS
- MongoDB

Development Guidelines
----------------------
- **Modularity**. Following the principle "loose coupling and high cohesion", each module should be standalone.
- **Minimalism**. Each module should be kept short, simple, and concise. Every piece of code should be transparent upon first reading.
- **Easy extensibility**. New modules (as new classes and functions) are should be simply add, and existing modules should be extended easily.
- **Code clean**. Code should be self-explanatory, with small amounts of comments if necessary.
- **Code review**. All developments must be done in branches; all commits must be review. 
