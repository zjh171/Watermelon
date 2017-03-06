function hello(){
   // alert("hello");
    window.location.href= 'hybrid://forward?param=\{\"topage\":\"kyson\",\"animate\":\"push\"\}';

}


function hello1(){
    // alert("hello");
    
    window.location.href= 'hybrid://updateNavigationBar?param={"data":{"left":[{"tagName":"back","callBack":"head_back","icon":"xxx.png","buttonType ":2}],"right":[{"tagName":"search","callBack":"head_search","buttonText":"按钮文字","buttonType ":1,"buttonTextColor":"#CCCCCC "}],"title":{"title":"标题","titleColor":"#CCCCCC","background":"#DDDDDD"}},"errorCode":0,"msg":"success"}';
    
}

function hello2(){
    // alert("hello");
    window.location.href= 'hybrid://back?param={}';
    
}

function hello3(){
    // alert("hello");
    window.location.href= 'hybrid://getLocation?param={}';
    
}


function hello4(){
    // alert("hello");
    window.location.href= 'hybrid://getNetWorkType?param={}';
    
}


function hello5(){
    // alert("hello");
    window.location.href= 'hybrid://getSystemInfo?param={}';
    
}




