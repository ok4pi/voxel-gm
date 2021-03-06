{
  "optionsFile": "options.json",
  "options": [],
  "exportToGame": true,
  "supportedTargets": -1,
  "extensionVersion": "0.0.1",
  "packageId": "",
  "productId": "",
  "author": "",
  "date": "2021-07-01T19:17:47.9379549-04:00",
  "license": "",
  "description": "",
  "helpfile": "",
  "iosProps": false,
  "tvosProps": false,
  "androidProps": false,
  "installdir": "",
  "files": [
    {"filename":"voxel.dll","origname":"","init":"RegisterCallbacks","final":"","kind":1,"uncompress":false,"functions":[
        {"externalName":"RegisterCallbacks","kind":1,"help":"RegisterCallbacks(f1, f2, f3, f4)","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
            1,
            1,
            1,
          ],"resourceVersion":"1.0","name":"RegisterCallbacks","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"voxel_init","kind":1,"help":"voxel_init(buffer)","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
          ],"resourceVersion":"1.0","name":"voxel_init","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"voxel_seed","kind":1,"help":"voxel_seed(seed)","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
          ],"resourceVersion":"1.0","name":"voxel_seed","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"voxel_step","kind":1,"help":"voxel_step(x, y)","hidden":false,"returnType":2,"argCount":0,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"voxel_step","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"voxel_spawn","kind":1,"help":"voxel_spawn(data, x, y)","hidden":false,"returnType":2,"argCount":0,"args":[
            1,
            2,
            2,
          ],"resourceVersion":"1.0","name":"voxel_spawn","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"voxel_can_spawn","kind":1,"help":"voxel_can_spawn()","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"voxel_can_spawn","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[],"ProxyFiles":[],"copyToTargets":-1,"order":[
        {"name":"RegisterCallbacks","path":"extensions/ext_voxel/ext_voxel.yy",},
        {"name":"voxel_init","path":"extensions/ext_voxel/ext_voxel.yy",},
        {"name":"voxel_step","path":"extensions/ext_voxel/ext_voxel.yy",},
        {"name":"voxel_seed","path":"extensions/ext_voxel/ext_voxel.yy",},
        {"name":"voxel_spawn","path":"extensions/ext_voxel/ext_voxel.yy",},
        {"name":"voxel_can_spawn","path":"extensions/ext_voxel/ext_voxel.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
  ],
  "classname": "",
  "tvosclassname": null,
  "tvosdelegatename": null,
  "iosdelegatename": "",
  "androidclassname": "",
  "sourcedir": "",
  "androidsourcedir": "",
  "macsourcedir": "",
  "maccompilerflags": "",
  "tvosmaccompilerflags": "",
  "maclinkerflags": "",
  "tvosmaclinkerflags": "",
  "iosplistinject": null,
  "tvosplistinject": null,
  "androidinject": null,
  "androidmanifestinject": null,
  "androidactivityinject": null,
  "gradleinject": null,
  "iosSystemFrameworkEntries": [],
  "tvosSystemFrameworkEntries": [],
  "iosThirdPartyFrameworkEntries": [],
  "tvosThirdPartyFrameworkEntries": [],
  "IncludedResources": [],
  "androidPermissions": [],
  "copyToTargets": -1,
  "iosCocoaPods": "",
  "tvosCocoaPods": "",
  "iosCocoaPodDependencies": "",
  "tvosCocoaPodDependencies": "",
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
  "resourceVersion": "1.2",
  "name": "ext_voxel",
  "tags": [],
  "resourceType": "GMExtension",
}