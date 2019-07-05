module.exports = {
  generate: function(json) {
    let html = ''
	for(let i=0; i<json.length; i++)
	{
      let tag = json[i].tag
	  let beginTag = '<'  + tag + '>'
	  let endTag   = '</' + tag + '>'
	  if(tag == 'code')
	  {
        beginTag = '<code><pre>'
        endTag   = '</pre></code>'
	  }
	  else if(tag == 'img')
      {
        html += '<img src="' + encodeURI(json[i].content) + '" />\n'
        continue
      }
	  else if(tag == 'a')
      {
        html += '<a href="' + encodeURI(json[i].content) + '">' + json[i].content + '</a>\n'
        continue
      }
      else if(tag == 'entry')
	  {
        html += '<a href="/#/wiki/entry/' + encodeURI(json[i].content) + '">' + json[i].content + '</a>\n'
        continue
	  }
	  else if(tag == 'ul')
	  {
        html += beginTag + '\n'
        for(let j=0; j<json[i].items.length; j++)
        {
          html += '<li>' + json[i].items[j] + '<li>\n'
        }
        html += endTag + '\n'
		continue
	  }
      html += beginTag
		   +  json[i].content.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br />')
		   +  endTag + '\n'
	}
	return html
  }
}

