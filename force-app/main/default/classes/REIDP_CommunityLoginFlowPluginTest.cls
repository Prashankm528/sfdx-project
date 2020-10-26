/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 12/2017
 *
 * A test class for REIDP_CommunityLoginFlowPlugin
 */
@isTest 
public class REIDP_CommunityLoginFlowPluginTest {

    @isTest
    static void testPlugin() {
        Test.startTest();
        REIDP_CommunityLoginFlowPlugin plugin = new REIDP_CommunityLoginFlowPlugin();
        plugin.describe();
        Map<String,Object> inputParams = new Map<String,Object>();
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult result = plugin.invoke(request);
        System.assertEquals(result.outputParameters.get('CommunityPrefix'),'NO_COMMUNITY');       
        Test.stopTest();
    }
}