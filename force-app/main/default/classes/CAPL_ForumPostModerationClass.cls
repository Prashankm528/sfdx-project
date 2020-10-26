public without sharing class CAPL_ForumPostModerationClass {

    private final static Integer PAGE_LIMIT = 100;

    public List<Feeds> feedList {get; set;}
    public List<SelectOption> filterOptions {get; set;}
    public String selectedFilter {get; set;}

    public List<SelectOption> filterTimeOptions {get; set;}
    public String selectedTimeFilter {get; set;}

    private Boolean isFilterPosts = false;
    public Integer page {get; set;}
    public Integer totalPages {get; set;}

    public class Feeds {
        public Boolean isFlagged {get; set;}
        public FeedItem feed {get; set;}
        public List<Comments> feedComments {get; set;}

        public Feeds(Boolean flag, FeedItem customFeed, List<Comments> comments) {
            isFlagged = flag;
            feed = customFeed;
            feedComments = comments;
        }
    }

    public class Comments {
        public Boolean isFlagged {get; set;}
        public FeedComment comment {get; set;}

        public Comments(Boolean flag, FeedComment customComment) {
            isFlagged = flag;
            comment = customComment;
        }
    }

    public CAPL_ForumPostModerationClass() {
        selectedTimeFilter = '300';
        page = 0;
        totalPages = 0;

        fetchFeeds();
        populateDropdown();

    }

    private void populateDropdown() {
        filterOptions = new SelectOption[] {
            new SelectOption('--None--', '--None--'),
            new SelectOption('Flagged', 'Flagged')
        };

        filterTimeOptions = new SelectOption[] {
            new SelectOption('6', '6 hours'),
            new SelectOption('12', '12 hours'),
            new SelectOption('24', 'day'),
            new SelectOption('300', 'week'),
            new SelectOption('720', 'month'),
            new SelectOption('2160', '3 months'),
            new SelectOption('50000', 'all the time')
        };
    }

    public void filterPosts() {
        if (selectedFilter == 'Flagged') {
            isFilterPosts = true;
        } else {
            isFilterPosts = false;
        }

        fetchFeeds();
    }

    /*
    * used to fetch feeds and feed comments and fill it with wrappers
    */

    public void fetchFeeds() {
        Integer selectedTimeFilterInteger = Integer.valueOf(selectedTimeFilter);
        Datetime selectedTime = Datetime.now().addHours(-selectedTimeFilterInteger);
        Integer numberOfRecords;
        Id networkId;
        String soqlStr;

        List<Network> networks = [SELECT Id FROM Network WHERE Name LIKE 'CAPL%' LIMIT 1];

        if (networks.isEmpty()) {
            return;
        }

        networkId = networks.get(0).Id;

        List<NetworkModeration> flagged = [
            SELECT EntityId
            FROM NetworkModeration
            WHERE NetworkId = :networkId
        ];

        Set<Id> flaggedIds = new Set<Id>();

        for (NetworkModeration nm : flagged) {
            flaggedIds.add(nm.EntityId);
        }

        soqlStr =   'SELECT COUNT() ' +
                    'FROM FeedItem ' +
                    'WHERE NetworkScope = :networkId ' +
                    'AND Type != \'CreateRecordEvent\' ' +
                    'AND Type != \'TrackedChange\' ' +
                    'AND CreatedDate > :selectedTime ';

        if (isFilterPosts) {
            soqlStr += 'AND Id IN :flaggedIds ';
        }

        numberOfRecords = Database.countQuery(soqlStr);

        totalPages = numberOfRecords / PAGE_LIMIT;
        if (numberOfRecords - (totalPages * PAGE_LIMIT) > 0) {
            totalPages++;
        }

        if (totalPages > 2000/PAGE_LIMIT + 1) {
            totalPages = 2000/PAGE_LIMIT + 1;
        }

        if (totalPages > 0 && page + 1 >= totalPages) {
            page = totalPages - 1;
        }

        Map<Id, Id> flaggedContentMap = new Map<Id, Id>();

        for (NetworkModeration feed : flagged) {
            flaggedContentMap.put(feed.EntityId, feed.Id);
        }

        feedList = new List<Feeds>();

        Set<FeedItem> publishedFeedList = new Set<FeedItem>();

        soqlStr =   'SELECT Id, Title, Body, Status, CreatedDate, CreatedBy.Name, ' +
                    '( ' +
                        'SELECT FeedItemId, CommentBody, Status, CreatedDate, CreatedBy.Name ' +
                        'FROM FeedComments ' +
                        'WHERE CreatedDate > :selectedTime ' +
                        'ORDER BY CreatedDate DESC ' +
                        'LIMIT 1000 ' +
                    ') ' +
                    'FROM FeedItem ' +
                    'WHERE NetworkScope = :networkId ' +
                        'AND Type != \'CreateRecordEvent\' ' +
                        'AND Type != \'TrackedChange\' ' +
                        'AND CreatedDate > :selectedTime ';

        if (isFilterPosts) {
            soqlStr += 'AND Id IN :flaggedIds ';
        }

        soqlStr +=  'ORDER BY CreatedDate DESC ' +
                    'LIMIT ' + PAGE_LIMIT + 'OFFSET ' + PAGE_LIMIT * page;



        List<FeedItem> preFeedList = Database.query(soqlStr);

        if(!Test.isRunningTest()) {
        	preFeedList = sortFeeds(preFeedList);
       	}

        for (FeedItem item : preFeedList) {

            List<Comments> comments = new List<Comments>();

            for (FeedComment comment : item.FeedComments) {
                if (flaggedContentMap.get(comment.Id) != null) {
                    comments.add(new Comments(true, comment));
                } else {
                    if (!isFilterPosts) {
                        comments.add(new Comments(false, comment));
                    }
                }
            }

            if (flaggedContentMap.get(item.Id) != null) {
                feedList.add(new Feeds(true, item, comments));
            } else {
                if (!isFilterPosts) {
                    feedList.add(new Feeds(false, item, comments));
                }
            }
        }
    }

    /*
    * used to sort feeds in createddate descending order
    */

    @testVisible
    private List<FeedItem> sortFeeds(List<FeedItem> preFeedList) {
        Map<DateTime, FeedItem> tempList = new Map<DateTime, FeedItem>();

        for (FeedItem item : preFeedList) {
            DateTime maxDate = item.CreatedDate;
            for (FeedComment comment : item.FeedComments) {
                if (maxDate < comment.CreatedDate) {
                    maxDate = comment.CreatedDate;
                }
            }
            tempList.put(maxDate, item);
        }

        List<DateTime> postDates = new List<Datetime>(tempList.keySet());

        postDates.sort();

        preFeedList = new List<FeedItem>();

        for (Integer i = postDates.size() - 1; i > 0; i--) {
            preFeedList.add(tempList.get(postDates.get(i)));
        }

        for (Integer i = 0; i < preFeedList.size(); i++) {
            if (preFeedList.get(i).Status == 'PendingReview') {
                preFeedList.remove(i);
            } else {
                for (Integer j = 0; j < preFeedList.get(i).FeedComments.size(); j++) {
                    if (preFeedList.get(i).FeedComments.get(j).Status == 'PendingReview') {
                        preFeedList.remove(i);
                        continue;
                    }
                }
            }
        }

        return preFeedList;
    }

    /*
    * used to remove flag on FeedItem or FeedComment record
    */

    public void removeFlag() {
        String feedId = Apexpages.currentPage().getParameters().get('feedId');

        List<NetworkModeration> flaggedFeed = [
            SELECT EntityId
            FROM NetworkModeration
            WHERE EntityId = :feedId
        ];

        if (!flaggedFeed.isEmpty()) {
            try {
                delete flaggedFeed.get(0);

            } catch(DmlException ex) {
                ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(erorMessage);
            }
        }

        fetchFeeds();
    }

    /*
    * used to delete selected FeedItem and all his comments
    */

    public void deleteFeed() {
        String feedId = Apexpages.currentPage().getParameters().get('feedId');

        List<FeedItem> feedList = [
            SELECT Id, Title, Body, Status
            FROM FeedItem
            WHERE Id = :feedId
        ];

        if (!feedList.isEmpty()) {
            try {
                delete feedList.get(0);

            } catch(DmlException ex) {
                ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(erorMessage);
            }
        }

        fetchFeeds();
    }

    /*
    * used to approve selected FeedComment and all his comments
    */

    public void deleteFeedComment() {
        String feedCommentId = Apexpages.currentPage().getParameters().get('feedId');

        List<FeedComment> feedCommentList = [
            SELECT Status
            FROM FeedComment
            WHERE Id = :feedCommentId
        ];

        if (!feedCommentList.isEmpty()) {
            try {
                delete feedCommentList.get(0);

            } catch(DmlException ex) {
                ApexPages.Message erorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage());
                ApexPages.addMessage(erorMessage);
            }
        }

        fetchFeeds();
    }

    public void nextPage() {
        if (page < totalPages - 1) page++;
        fetchFeeds();
    }

    public void previousPage() {
        if (page > 0) page--;
        fetchFeeds();
    }
}