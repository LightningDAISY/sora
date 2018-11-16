function basicRequest(method, uri, data)
{
	const form = new FormData()
	if(data)
	{
		for(key in data)
		{
			form.append(key, data[key])
		}
	}
	fetch(
		uri,
		{
			method: method,
			headers: {
				"User-Agent" : "Mozilla/5.0"
			},
			body: form
		}
	)
	.then(
		function(res) { return(res.json()) }
	)
	.then(
		function(json) {
			if(json.result && json.result == "OK")
			{
				location.reload(false)
			}
			else
			{
				alert("error")
			}
		},
		function(res) { alert("error " + res) }
	)
}

function newDirectory()
{
	const input = prompt("directory name")
	if(!input) { return }
	basicRequest("POST", location.href, { "directoryName" : input })
}

function renameNode()
{
	var path = this.parentNode.getAttribute("path")
	path = path.replace(document.querySelector("#baseUri").innerText + "/", "")

	const input = prompt("input a new name", path)
	if(!input) { return }
	basicRequest(
		"PUT",
		this.parentNode.getAttribute("path"),
		{ "newName" : input }
	)
}

function freezeNode()
{
	basicRequest(
		"OPTIONS",
		this.parentNode.getAttribute("path")
	)
}

function removeNode()
{
	const filePath = this.parentNode.getAttribute("path")
	const parts = filePath.split(/\//)
	if(!confirm("remove " + parts[parts.length - 1] + "?")) { return }
	basicRequest("DELETE", filePath)
}

function copyUri()
{
	const fileUri = this.parentNode.getAttribute("uri")
	const founds = location.href.match(/^(http:\/\/.+?)\//)
	if(navigator.clipboard)
	{
		navigator.clipboard.writeText(founds[1] + fileUri)
		alert("copied " + founds[1] + fileUri)
	}
	else
	{
		alert(founds[1] + fileUri)
	}
}

function createEmptyDirectory(id,parentHeader)
{
	const FM  = document.querySelector(id)
	const a1  = document.createElement("a")
	const td1 = document.createElement("td")
	const td2 = document.createElement("td")
	const td3 = document.createElement("td")
	const td4 = document.createElement("td")
	const tr  = document.createElement("tr")

	a1.setAttribute("href", parentHeader)
	a1.innerHTML = ".."
	td1.appendChild(a1)
	td2.innerText = " "
	tr.appendChild(td1)
	tr.appendChild(td2)
	tr.appendChild(td3)
	tr.appendChild(td4)
	FM.appendChild(tr)
	return FM
}

function createButton(name,id,func)
{
	const spanName = document.createElement("span")
	const td = document.createElement("td")
	spanName.innerText = name
	td.appendChild(spanName)
	td.setAttribute("id", id)
	td.classList.add("clickable")
	if(func)
	{
		td.addEventListener("click", func)
	}
	return td
}

function renderPanel(parentUri)
{
	const newDirectoryButton = document.createElement("button")
	newDirectoryButton.innerText = "create a new directory"
	newDirectoryButton.classList.add("create-new-directory")
	newDirectoryButton.addEventListener("click", newDirectory)
	const panel = document.querySelector("#filePanel")
	panel.appendChild(newDirectoryButton)
}

function renderList(json, parentHeader)
{
	const FM = createEmptyDirectory("#fileList", parentHeader)
	var id = 1
	const baseUri = document.querySelector("#baseUri").innerHTML
	for(key in json)
	{
		const a1  = document.createElement("a")
		const tr  = document.createElement("tr")
		const td1 = document.createElement("td")
		const td2 = document.createElement("td")
		if(json[key].isDirectory)
		{
			a1.setAttribute("href", json[key].fmuri)
			tr.setAttribute("uri",  json[key].fmuri)
		}
		else
		{
			a1.setAttribute("href", json[key].uri)
			tr.setAttribute("uri",  json[key].uri)
		}
		a1.innerText  = json[key].name
		td2.innerText = json[key].permissionString
		td2.classList.add("permission")
		td1.appendChild(a1)
		tr.appendChild(td1)
		tr.appendChild(td2)
		if(json[key].lockedBy)
		{
			tr.appendChild(createButton("-", id++))
			tr.appendChild(createButton("-", id++))
			tr.appendChild(createButton("unlock (locked by " + json[key].userNickname + ")" , id++, freezeNode))
		}
		else
		{
			tr.appendChild(createButton("rename", id++, renameNode))
			tr.appendChild(createButton("remove", id++, removeNode))
			tr.appendChild(createButton("lock",   id++, freezeNode))
		}
		if(json[key].isDirectory)
		{
			const td3 = document.createElement("td")
			tr.appendChild(td3)
		}
		else
		{
			tr.appendChild(createButton("copy", id++, copyUri))
		}
		tr.setAttribute("path", baseUri + "/" + json[key].path)
		tr.setAttribute("name", json[key].name)
		FM.appendChild(tr)
	}
	return 1
}

function uploadFile(event)
{
	event.preventDefault()
	basicRequest(
		"PUT",
		location.href,
		{
			newFile : event.dataTransfer.files[0]
		}
	)
}

function showCurrent(baseUri, requestPath)
{
	const requestUri = baseUri + requestPath
	var parentHeader = "/"
	fetch(
		requestUri,
		{
			method: "GET",
			headers: {
				"User-Agent" : "Mozilla/5.0"
			}
		}
	)
	.then(
		function(res) {
			parentHeader = res.headers.get("X-Parent-Path")
			return(res.json())
		}
	)
	.then(
		function(json) {
			renderPanel(parentHeader, requestPath)
			renderList(json, parentHeader)
		},
		function(res) { alert("error " + res) }
	)
}

