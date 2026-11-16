import fs from 'fs';
import * as cheerio from 'cheerio';

const doc = fs.readFileSync("build/index.html","utf8");
const $ = cheerio.load(doc);

const headHtml = $('head').html();

const headLinks = $('head link');

// array to populate
let mapAssets = [];

// loop through links
headLinks.each(function(i,el){
	const url = $(el).attr("href");
	let fileType;

	if(url.includes(".css")) fileType = "css";
	if(url.includes(".js")) fileType = "js";
	
	// add css and js to assets
	if(fileType){
		mapAssets.push({"type": fileType,
						url})
	}

});


const bodySection= $('body').html();

let fullString = `<script>

const mapAssets = ${JSON.stringify(mapAssets)}

mapAssets.forEach(asset => {
  const link = document.createElement('link');
  link.rel = asset.type === 'css' ? 'stylesheet' : 'modulepreload';
  link.href = asset.url;
  document.head.appendChild(link);
});

document.querySelector('#content.site-content').style.overflow = 'clip';
</script>

${bodySection}

`;

// write file
fs.writeFileSync("EMBED-CODE.js",fullString,"utf8");


