({
	convertUsersToCSV : function(component,usersList) {

        var csvResult = '';
        var counter;
        var header = ['Name','Username','LanguageLocaleKey','LastLoginDate'];
        var columnDivider = ',';
        var lineDivider = '\n';
       
        if (usersList == null || !usersList.length) {
            return null;
         }

        csvResult += header.join(columnDivider);
        csvResult += lineDivider;
 
        for (var i = 0; i < usersList.length; i++) {
		    counter = 0;

		    for (var headerItem in header) {
		        var fieldName = header[headerItem];

		        if (counter > 0) {
		            csvResult += columnDivider;
		        }

		        csvResult += '"' + usersList[i][fieldName] + '"';

		        counter++;

		    } 
		    csvResult += lineDivider;
		}
       
        return csvResult;        
    },
})