#S2M-Facebook

This is a wrapper for the Facebook iOS SDK.

Take a look at the sample, run *s2m-facebook-iOS/scripts/build_s2m_facebook_framework.sh* to build the framework version of the project.

To include the wrapper into your project, simply add the S2M-Facebook.framework in */s2m-facebook-iOS/s2m-facebook-iOS/framework/S2M-Facebook.framework* to your project.

Please report all bugs.

Merge requests with bug-fixes are more than welcome.

##Setup

	git clone git@github.com:sinnerschrader-mobile/S2M-Facebook-iOS.git S2M-Facebook-iOS.git
	cd S2M-Facebook-iOS.git
	git submodule update --init
	sh s2m-facebook-iOS/scripts/build_s2m_facebook_framework.sh

##License

	 Copyright 2012 SinnerSchrader Mobile GmbH.
	 
	 Licensed under the Apache License, Version 2.0 (the "License");
	 you may not use this file except in compliance with the License.
	 You may obtain a copy of the License at
	 
	 http://www.apache.org/licenses/LICENSE-2.0
	 
	 Unless required by applicable law or agreed to in writing, software
	 distributed under the License is distributed on an "AS IS" BASIS,
	 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 See the License for the specific language governing permissions and
	 limitations under the License.