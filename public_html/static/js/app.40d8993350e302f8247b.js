webpackJsonp([1],{"6XTM":function(e,t,r){"use strict";var i={render:function(){var e=this.$createElement;return(this._self._c||e)("p",[this._v("\n  Login?\n")])},staticRenderFns:[]};t.a=i},FhoZ:function(e,t,r){"use strict";(function(t){const i=r("o/zv");e.exports={dev:{assetsSubDirectory:"static",assetsPublicPath:"/",proxyTable:{},host:"swagger-server.local",port:8080,api:{scheme:"http",host:"swagger-server.local",uri:"/sora",port:8e3},autoOpenBrowser:!1,errorOverlay:!0,notifyOnErrors:!0,poll:!1,useEslint:!1,showEslintErrorsInOverlay:!1,devtool:"cheap-module-eval-source-map",cacheBusting:!0,cssSourceMap:!0},build:{index:i.resolve(t,"../dist/index.html"),assetsRoot:i.resolve(t,"../dist"),assetsSubDirectory:"static",assetsPublicPath:"/",api:{scheme:"http",host:"swagger-server.local",uri:"/sora",port:8e3},productionSourceMap:!0,devtool:"#source-map",productionGzip:!1,productionGzipExtensions:["js","css"],bundleAnalyzerReport:Object({NODE_ENV:"production",URI_LOGIN:"http://swagger-server.local:8000/sora/auth/user/login"}).npm_config_report}}}).call(t,"/")},KuRe:function(e,t){},NHnr:function(e,t,r){"use strict";Object.defineProperty(t,"__esModule",{value:!0});var i=r("7+uW"),n={render:function(){var e=this.$createElement,t=this._self._c||e;return t("div",{attrs:{id:"app"}},[t("link",{attrs:{rel:"stylesheet",type:"text/css",href:"/static/app.css"}}),this._v(" "),t("link",{attrs:{rel:"stylesheet",type:"text/css",href:"/static/font-awesome.css"}}),this._v(" "),t("router-view")],1)},staticRenderFns:[]},a=r("VU/8")({name:"App"},n,!1,null,null,null).exports,s=r("/ocq"),o=r("FhoZ"),l=r.n(o),c={methods:{renderList:function(e,t){var r=createEmptyDirectory("#fileList",t),i=1,n=document.querySelector("#baseUri").innerHTML;for(key in e){var a=document.createElement("a"),s=document.createElement("tr"),o=document.createElement("td"),l=document.createElement("td");if(e[key].isDirectory?(a.setAttribute("href",e[key].fmuri),s.setAttribute("uri",e[key].fmuri)):(a.setAttribute("href",e[key].uri),s.setAttribute("uri",e[key].uri)),a.innerText=e[key].name,l.innerText=e[key].permissionString,l.classList.add("permission"),o.appendChild(a),s.appendChild(o),s.appendChild(l),e[key].lockedBy?(s.appendChild(createButton("-",i++)),s.appendChild(createButton("-",i++)),s.appendChild(createButton("unlock (locked by "+e[key].userNickname+")",i++,freezeNode))):(s.appendChild(createButton("rename",i++,renameNode)),s.appendChild(createButton("remove",i++,removeNode)),s.appendChild(createButton("lock",i++,freezeNode))),e[key].isDirectory){var c=document.createElement("td");s.appendChild(c)}else s.appendChild(createButton("copy",i++,copyUri));s.setAttribute("path",n+"/"+e[key].path),s.setAttribute("name",e[key].name),r.appendChild(s)}return 1},basicRequest:function(e,t,r,i){var n=new FormData;if(r)for(var a in r)n.append(a,r[a]);var s={method:e,headers:{"User-Agent":"Mozilla/5.0"}};"GET"!=e&&"HEAD"!=e&&(s.body=n),fetch(t,s).then(function(e){return e.json()}).then(function(e){e.result&&i(e)},function(e){alert("error "+e)})}}},d={name:"TopMenu",mixins:[c],mounted:function(){this.basicRequest("GET",this.api.scheme+"://"+this.api.host+":"+this.api.port+this.api.uri+"/user/info",null,function(e){"OK"==e.result?document.querySelector("#topmenu-login").innerHTML="Logout":document.querySelector("#topmenu-login").innerHTML="Login"})},data:function(){return{api:l.a.dev.api}}},u={render:function(){var e=this,t=e.$createElement,r=e._self._c||t;return r("nav",{staticClass:"nav"},[r("div",{staticClass:"nav-left"},[r("router-link",{staticClass:"nav-item is-brand",attrs:{to:"/"}},[e._v("Swagger Server")])],1),e._v(" "),r("div",{staticClass:"nav-center"},[r("router-link",{staticClass:"nav-item",attrs:{to:"/"}},[e._v("Home")]),e._v(" "),r("a",{staticClass:"nav-item",attrs:{href:e.api.scheme+"://"+e.api.host+":"+e.api.port+"/static/swagger/editor"}},[e._v("Editor")]),e._v(" "),r("a",{staticClass:"nav-item",attrs:{href:e.api.scheme+"://"+e.api.host+":"+e.api.port+"/static/swagger/ui"}},[e._v("UI")]),e._v(" "),r("router-link",{staticClass:"nav-item",attrs:{to:"/file"}},[e._v("FileManager")])],1),e._v(" "),r("div",{staticClass:"nav-right nav-menu"},[r("span",{staticClass:"nav-item"},[r("router-link",{staticClass:"button",attrs:{to:"/mypage"}},[r("span",[e._v("MyPage")])]),e._v(" "),r("a",{staticClass:"button is-primary",attrs:{href:e.api.scheme+"://"+e.api.host+":"+e.api.port+e.api.uri+"/auth/user/login"}},[r("span",{attrs:{id:"topmenu-login"}},[e._v("Auth")])])],1)])])},staticRenderFns:[]},p=r("VU/8")(d,u,!1,null,null,null).exports,m={components:{TopMenu:p},name:"FrontPage",mixins:[c],mounted:function(){this.basicRequest("GET",this.uri.mypage,null,function(e){document.querySelector("#nickname").innerHTML=e.nickname,document.querySelector("#loginId").innerHTML=e.userName,document.querySelector("#mailAddress").innerHTML=e.mailAddress,document.querySelector("#role").innerHTML=e.role,document.querySelector("#personality").innerHTML=e.personality,document.querySelector("#at").innerHTML=Date(e.createdAt+"000")})},data:function(){return{uri:{mypage:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/mypage.json",modify:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/modify"},bind:{}}}},v={render:function(){var e=this.$createElement,t=this._self._c||e;return t("div",{staticClass:"front"},[t("TopMenu"),this._v(" "),this._m(0),this._v(" "),t("div",{staticStyle:{"text-align":"center"}},[t("blockquotes",[t("a",{staticClass:"button is-info",attrs:{href:this.uri.modify}},[this._v("modify")])])],1)],1)},staticRenderFns:[function(){var e=this,t=e.$createElement,r=e._self._c||t;return r("div",[r("table",{staticClass:"table is-bordered is-striped is-narrow"},[r("tr",[r("th",[e._v("Nickname")]),r("td",{attrs:{id:"nickname"}})]),e._v(" "),r("tr",[r("th",[e._v("Login ID")]),r("td",{attrs:{id:"loginId"}})]),e._v(" "),r("tr",[r("th",[e._v("Mail address")]),r("td",{attrs:{id:"mailAddress"}})]),e._v(" "),r("tr",[r("th",[e._v("Role")]),r("td",{attrs:{id:"role"}})]),e._v(" "),r("tr",[r("th",[e._v("Personality")]),r("td",{attrs:{id:"personality"}})]),e._v(" "),r("tr",[r("th",[e._v("Joined")]),r("td",{attrs:{id:"at"}})])])])}]},h=r("VU/8")(m,v,!1,null,null,null).exports,y=r("xJsL"),f={components:{TopMenu:p},name:"MyPage",mixins:[c],data:function(){return{nickname:"",uri:{mypage:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/mypage.json",modify:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/modify"},bind:{}}},mounted:function(){this.basicRequest("GET",this.uri.mypage,null,function(e){"NG"===e.result&&(location.href="http://swagger-server.local:8000/sora/auth/user/login"),document.querySelector("#nickname").innerHTML=e.nickname,document.querySelector("#loginId").innerHTML=e.userName,document.querySelector("#mailAddress").innerHTML=e.mailAddress,document.querySelector("#role").innerHTML=e.role,document.querySelector("#personality").innerHTML=e.personality,document.querySelector("#at").innerHTML=Date(e.createdAt+"000")})}},_={render:function(){var e=this.$createElement,t=this._self._c||e;return t("div",{staticClass:"front"},[t("TopMenu"),this._v(" "),this._m(0),this._v(" "),t("div",{staticStyle:{"text-align":"center"}},[t("blockquotes",[t("a",{staticClass:"button is-info",attrs:{href:this.uri.modify}},[this._v("modify")])])],1)],1)},staticRenderFns:[function(){var e=this,t=e.$createElement,r=e._self._c||t;return r("div",[r("table",{staticClass:"table is-bordered is-striped is-narrow"},[r("tr",[r("th",[e._v("Nickname")]),r("td",{attrs:{id:"nickname"}})]),e._v(" "),r("tr",[r("th",[e._v("Login ID")]),r("td",{attrs:{id:"loginId"}})]),e._v(" "),r("tr",[r("th",[e._v("Mail address")]),r("td",{attrs:{id:"mailAddress"}})]),e._v(" "),r("tr",[r("th",[e._v("Role")]),r("td",{attrs:{id:"role"}})]),e._v(" "),r("tr",[r("th",[e._v("Personality")]),r("td",{attrs:{id:"personality"}})]),e._v(" "),r("tr",[r("th",[e._v("Joined")]),r("td",{attrs:{id:"at"}})])])])}]},g=r("VU/8")(f,_,!1,null,null,null).exports,b={components:{TopMenu:p},name:"FileManager",mixins:[c],mounted:function(){this.basicRequest("GET",this.uri.mypage,null,function(e){document.querySelector("#nickname").innerHTML=e.nickname,document.querySelector("#loginId").innerHTML=e.userName,document.querySelector("#mailAddress").innerHTML=e.mailAddress,document.querySelector("#role").innerHTML=e.role,document.querySelector("#personality").innerHTML=e.personality,document.querySelector("#at").innerHTML=Date(e.createdAt+"000")})},data:function(){return{uri:{mypage:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/mypage.json",modify:l.a.dev.api.scheme+"://"+l.a.dev.api.host+":"+l.a.dev.api.port+l.a.dev.api.uri+"/user/modify"},bind:{}}}},k={render:function(){var e=this.$createElement,t=this._self._c||e;return t("div",{staticClass:"front"},[t("TopMenu"),this._v(" "),this._m(0),this._v(" "),t("div",{staticStyle:{"text-align":"center"}},[t("blockquotes",[t("a",{staticClass:"button is-info",attrs:{href:this.uri.modify}},[this._v("modify")])])],1)],1)},staticRenderFns:[function(){var e=this,t=e.$createElement,r=e._self._c||t;return r("div",[r("table",{staticClass:"table is-bordered is-striped is-narrow"},[r("tr",[r("th",[e._v("Nickname")]),r("td",{attrs:{id:"nickname"}})]),e._v(" "),r("tr",[r("th",[e._v("Login ID")]),r("td",{attrs:{id:"loginId"}})]),e._v(" "),r("tr",[r("th",[e._v("Mail address")]),r("td",{attrs:{id:"mailAddress"}})]),e._v(" "),r("tr",[r("th",[e._v("Role")]),r("td",{attrs:{id:"role"}})]),e._v(" "),r("tr",[r("th",[e._v("Personality")]),r("td",{attrs:{id:"personality"}})]),e._v(" "),r("tr",[r("th",[e._v("Joined")]),r("td",{attrs:{id:"at"}})])])])}]},M=r("VU/8")(b,k,!1,null,null,null).exports;i.a.use(s.a);var T=new s.a({mode:"history",routes:[{path:"/login",name:"login",component:y.default},{path:"/",name:"FrontPage",component:h},{path:"/mypage",name:"mypage",component:g},{path:"/file",name:"filemanager",component:M}]});i.a.config.productionTip=!1,new i.a({el:"#app",router:T,components:{App:a},template:"<App/>"})},"nKb+":function(e,t){},xJsL:function(e,t,r){"use strict";var i=r("nKb+"),n=r.n(i),a=r("6XTM");var s=function(e){r("KuRe")},o=r("VU/8")(n.a,a.a,!1,s,null,null);t.default=o.exports}},["NHnr"]);
//# sourceMappingURL=app.40d8993350e302f8247b.js.map