/**
 * @author Nazim Aliyev
 * @company Bluewolf, an IBM Company
 * @date 12/2017
 *
 * A Flow Plugin used to determine current Cummunity in use
 */
global class REIDP_CommunityLoginFlowPlugin implements Process.Plugin { 
    
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter> {
            new Process.PluginDescribeResult.OutputParameter('CommunityPrefix',
                Process.PluginDescribeResult.ParameterType.String)
        };
        return result;
    }
    
    global Process.PluginResult invoke(Process.PluginRequest request) {   
        Map<String, Object> result = new Map<String, Object>();
        Network net;
        try {
            net = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];    
        } catch(Exception ex) {}
        result.put('CommunityPrefix', (net != null) ? net.UrlPathPrefix : 'NO_COMMUNITY');
        return new Process.PluginResult(result);
    }
}