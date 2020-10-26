@IsTest
private with sharing class CAJBP_LineSplitterTest {

    @IsTest
    private static void nullTest() {
        runTest(null, null, null);
    }

    @IsTest
    private static void noSplitTest() {
        runTest('asdf', null, 'asdf');
    }

    @isTest
    private static void simpleSplit() {
        String input = 'A sample string to split.';
        Integer lineLength = 13; // split is middle of 'string'
        String output = 'A sample' + CAJBP_LineSplitter.NEW_LINE +
            'string to' + CAJBP_LineSplitter.NEW_LINE +
            'split.';
        runTest(input, lineLength, output);
    }

    @IsTest
    private static void codeSplit() {
        String input = 'BEADI-MTVAD-9SEAA';
        Integer lineLength = 7;
        String output = 'BEADI-' + CAJBP_LineSplitter.NEW_LINE +
            'MTVAD-' + CAJBP_LineSplitter.NEW_LINE +
            '9SEAA';
        runTest(input, lineLength, output);
    }

    @IsTest
    private static void longWord() {
        String input = 'veryverylongword';
        Integer lineLength = 10;
        String output = 'veryveryl-' + CAJBP_LineSplitter.NEW_LINE +
            'ongword';
        runTest(input, lineLength, output);
    }

    private static void runTest(String input, Integer lineLength, String expected) {
        CAJBP_LineSplitter splitter = new CAJBP_LineSplitter();
        splitter.myInput = input;
        splitter.myLineLength = lineLength;
        System.assertEquals(expected, splitter.output);
    }
}