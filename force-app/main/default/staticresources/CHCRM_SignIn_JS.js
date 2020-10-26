var lng;
var lat;
var address;
var signInTime;

function displayModle(time,location,message,display,saveBtn,refreshBtn){
    $("#time").text(time);
    $("#location").text(location);
    $("#message").text(message);
    $('#loading').css('display',display);
    if (saveBtn) {
        $("#" + "myPage\\:myForm\\:saveBtn").attr("disabled","disabled");
    }else{
        $("#" + "myPage\\:myForm\\:saveBtn").removeAttr("disabled");
    }
    if (refreshBtn) {
        $("#" + "myPage\\:myForm\\:refreshBtn").attr("disabled","disabled");
    }else{
        $("#" + "myPage\\:myForm\\:refreshBtn").removeAttr("disabled");
    }
}

function isNull(variable){
    return (variable == "" || variable == null || variable == undefined) ? true : false;
}    

function getLocationInfo(){
    //Show loading
    displayModle("签到时间:","当前位置:","","block",true,true);
    //Initialize BMap components
    var geolocation = new BMap.Geolocation({enableHighAccuracy:true,maximumAge:10});
    var geocoder = new BMap.Geocoder();
    //Get lng & lat info
    geolocation.getCurrentPosition(function(r){
        if (isNull(r.point.lng) || isNull(r.point.lat)) {
            displayModle("","","获取地址信息失败，请刷新页面","none",true,true);
        }else{
            if(this.getStatus() == BMAP_STATUS_SUCCESS){
                //Get address info
                geocoder.getLocation(r.point,function(rs){
                    if (isNull(rs.addressComponents.province) || isNull(rs.addressComponents.city)) {
                        displayModle("","","获取地址信息失败，请刷新页面","none",true,true);
                    }else{
                        lng = r.point.lng;
                        lat = r.point.lat;
                        address = rs.addressComponents.province + rs.addressComponents.city + rs.addressComponents.district;
                        if (rs.surroundingPois.length > 0) {
                            address += rs.surroundingPois[0].title;
                        }else if (!isNull(rs.business)) {
                            address += rs.business.split(",")[0];
                        }
                        //Display current time and address
                        signInTime = new Date();
                        displayModle("签到时间:" + signInTime.toLocaleString(),"当前位置:" + address,"","none",false,false);
                    }
                });
            }
            else {
                displayModle("","","获取地址信息失败，请刷新页面","none",true,true);
            }
        }        
    });
}

function refreshBtn(){
    getLocationInfo();
}