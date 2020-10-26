/*****************************************************************************************
*       Date:        20 Dec 2019
*       Author:      Arron Kukadia - IBM
*       Description: Parses and stringified JSON object
*****************************************************************************************/

public class DUP_FileList {
    public String name;
    public String documentId;
    
    public static List<DUP_FileList> parseFiles(String json) {
        return (List<DUP_FileList>) System.JSON.deserialize(json, List<DUP_FileList>.class);
    }
}