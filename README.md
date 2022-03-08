# Environment

This repository houses documentation and tools used within the "ASP Web API" stack. Please view [the wiki](https://github.com/DOI-ONRR-IDS/Environment/wiki) for more information.

Below are the software and settings used to develop applications within our "ASP Web API" stack. Some alternatives exist that can do the job just as well but aren't supported by this documentation.

## Evergreen browser

The "ASP Web API" stack requires both developers and clients to use modern browsers. Any current version of Chrome, Edge, or Firefox should be suitable. No version of Internet Explorer is compatible.

While Chrome, Edge, and Firefox will mostly be interchangable, it is recommended to use Chrome (or a Chromium-based browser with access to extensions) for development. This because additional tooling in the form of browser extensions will be linked to below, which may not have versions or alternatives created for Edge and Firefox.

## Visual Studio 2019

Visual Studio is used to develop the backend files. Both Visual Studio 2019 and the .NET 5 SDK need to be installed. .NET 5 is not backwards-compatible with older versions of Visual Studio.

https://visualstudio.microsoft.com/vs/older-downloads/#visual-studio-2019-and-other-products

https://dotnet.microsoft.com/en-us/download/dotnet/5.0

\\ TODO

## VS Code

VS Code is used to develop the frontend files.

https://code.visualstudio.com/

\\ TODO

### Node & Node Package Manager (NPM)

Node is a JavaScript environment that is used to manage and bundle the frontend files.

https://nodejs.org/en/download/current/

Be sure to download a version >= 17.0.0. NPM will be installed with Node. You should install Chocolatey, if it offers.

After installation, open a PowerShell or Terminal window and run:
```bash
npm config set strict-ssl false
```

## git

Git is used as the version control software for our applications. It will need to be installed locally to interact with the repositories.

https://git-scm.com/downloads

After installing, open a new PowerShell or Terminal window and run:
```bash
git config --global http.sslbackend schannel
git config --global http.schannelCheckRevoke false
```

## Dev Tools

[Vue.js devtools](https://chrome.google.com/webstore/detail/vuejs-devtools/nhdogjmejiglipccpnnnanhbledajbpd) - Devtools integration for vue

## Troubleshooting

### SSL Errors

After installing git and NPM, you were instructed to run some terminal commands. Those commands solve the following SSL errors:

`unable to get local issuer certificate`

`The revocation function was unable to check revocation for the certificate.`

https://stackoverflow.com/a/46408398/3224736

https://stackoverflow.com/a/53064542/3224736

https://stackoverflow.com/a/53090169/3224736

## Reference
* [Vue](https://vuejs.org/v2/guide/)
* [Vue Router](https://router.vuejs.org/guide/)
* [Vuex](https://vuex.vuejs.org/guide/)
* [Vuetify](https://vuetifyjs.com/en/getting-started/installation/)
* [Material Design Icons](https://materialdesignicons.com/) (Use SVG syntax)
  * [MDI Picker](https://chrome.google.com/webstore/detail/materialdesignicons-picke/edjaedpifkihpjkcgknfokmibkoafhme)
* [lodash](https://lodash.com/docs) (Use individual import syntax)
* [Vue Upload Component](https://lian-yue.github.io/vue-upload-component/#/en/documents)
* [html2pdf](https://github.com/eKoopmans/html2pdf.js)
  * [html2canvas options](https://html2canvas.hertzen.com/configuration)
  * [jsPDF options](https://html2canvas.hertzen.com/configuration)
* [tiptap](https://www.tiptap.dev/examples/default/)
