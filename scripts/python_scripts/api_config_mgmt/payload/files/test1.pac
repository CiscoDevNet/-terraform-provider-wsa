"use strict";
function FindProxyForURL(url, host) {
  if (shExpMatch(url, "*.cs1*")){
	return "PROXY wsa260-p1.cs1:3128; DIRECT";
  } else {
    return "DIRECT";
  }
}