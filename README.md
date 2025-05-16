# sensibo-stuff

Sensibo's app UI is horrible when it comes to finding and identifying an appropriate model when you have a AC unit that doesn't fall under their existing model set, e.g. a brand and/or model that isn't listed.

They don't provide the ability to manually configure a custom model even if you know what the IR codes that should be sent are.

This repo contains a dump of responses from the Sensibo REST API, e.g. as documented [here](https://support.sensibo.com/api/) and [here](https://support.sensibo.com/sensibo.openapi.yaml).

models.json is the full body of response from the undocumented API endpoint at [https://home.sensibo.com/api/v2/acModels](https://home.sensibo.com/api/v2/acModels)

The individual files under /modelCapabilities/ are sub-set's of the repsonse from [https://support.sensibo.com/api/operations/podsdevice_id/](https://support.sensibo.com/api/operations/podsdevice_id/)

If you use the REST API to change the model of your "pod" you get a list of the capabilities for that model the next time you request the pod information under `.result.remoteCapabilities` in the body of the response.

A series of hastily smashed together shell scripts are in the repo which I found useful as a way to iterate over the avaiable models to identify capabilities to then search thru them to find potential models that fit my AC unit's specific capabilities, e.g. native Celcius temperature, cooling and fan only modes, temperature range from 16C to 30C, etc.

This was useful to me, hopefully it's useful to someone else too.

To the people at Sensibo, please just provide your customers the ability to define a custom local model in the app with manually configured IR codes.

The response to my support request regarding the lack of support for the AC unit I'm using was extremely lack lustre.

Your auto-detection has selected a model that does allow me to turn the AC unit on/off, but that's it. Zero control over temperature or fan speed.

Your team just replied with a meaningless bog standard response including continuing to claim that Sensibo supports all AC models.

Despite having provide the specific IR codes and make/model information they still havn't added it to the app.