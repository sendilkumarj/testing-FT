
if(!document.createElementNS || !document.createElementNS('http://www.w3.org/2000/svg','svg').createSVGRect){
	alert('We\'re Sorry, this visualization uses the SVG standard, most modern browsers support SVG. If you would like to see this visualization please view this page in another browser such as Google Chrome, Firefox, Safari, or Internet Explorer 9+');	
}

vex.defaultOptions.className = 'vex-theme-os';


var visMode = 'wave';			//the type of network to render, each has it own settings

var tripleStore = null;			//holds the triple data bank created by te rdfquery plugin
var tripleObject = null;		//holds the javascript seralized object of the triple store
var descStore = null;			//holds the triple data bank created by te rdfquery plugin for the description
var descObject = null;			//holds the javascript seralized object of the triple store for the description
var nameObject = null;			//holds the foaf names of the people
var largestNodes = [];			//holds a list of the N largest nodes/people (most connections) in order to place/lock them properly on render
var hidePopupTimer = null;		//holds the timer to close the popup
var showPopupTimer = null;		
var currentNode = null;			//the current node we are highligting
var usePerson = null;			//the person in person mode 
var usePersonIndex = 0;			//the index pos of the usePerson in the nodes array, so we dont have to loop through the whole thing everytime
var edgesAvg = 0;
var edgesInterval = 0			//the steps between the avg and largest # edges
var trans=[0,0];
var scale=0.99;
var dynamicPeople = [];			//holds who is added in the dynamic mode
var rendering = false;			//global to keep track if we are rendering from a click or a history pushstate change

var idLookup = {}				//holds nice names to uri conversion

var zoom = null;				//the d3.js zoom object
var baseNodes = [];				//stores the base (all) of the nodes and 
var baseLinks = [];				// links
var fileNames = [];
var metaNames  =[];
var force = null;				//the d3 force object
var vis = null					//the visualization
var visWidth = 1000;			//width and height of the network canvas, in px
var visHeight = 500;	

var connectionCounter = {};		//holds each  id as a property name w/ the value = # of connections they have

var connectionIndex = {};		//a object with properties as id names, with values an array of strings of ids that person has connections to.
var largestConnection = 0;		//


var simlarityIndex = {}			//properties are id names, with the value being an array of objects with other ids and their # of matching connections
var largestSimilarity = 0;		//holds the max number of similar connections any two nodes share in the network

var strokeWidth = 0.3;			//the defult width to make the stroke

								//the settings that vary for each diff type of network 
var networkGravity =  0;
var netwokrLinkLength = 35;
var networkLargeNodeLimit = 20;	//the number of top nodes to fix/lock to a patterend spot on the network
var netwokrCharge = -800;
var networkStopTick = true;		//when the alpha value drops to display the graph, do we stop the nodes from animating?
var networkNodeDrag = false;	//can you drag the nodes about?

var networkMinEdges = 2;		//the min number of edges to have a node be rendered

var cssSafe = new RegExp(/%|\(|\)|\.|\,|'|"/g);	//the regex to remove non css viable chars

var youTubeObject = '<object style="height=130px; width=200px; position: absolute; bottom: 0px;"> <param name="movie" value="https://www.youtube.com/v/<id>?version=3&feature=player_embedded&controls=1&enablejsapi=1&modestbranding=1&rel=0&showinfo=1&autoplay=1"><param name="allowFullScreen" value="true"><param name="wmode" value="transparent"><param name="allowScriptAccess" value="always"><embed src="https://www.youtube.com/v/<id>?version=3&feature=player_embedded&controls=1&enablejsapi=1&modestbranding=1&rel=0&showinfo=1&autoplay=1" type="application/x-shockwave-flash" allowfullscreen="true" allowScriptAccess="always" width="200" height="130" wmode="transparent"></object>';			
var zoomWidgetObj = null;			//the zoom widget draghandeler object
var zoomWidgetObjDoZoom = true;



var oldzoom = 0;

var fill = d3.scale.category10();
var lineColor = d3.scale.category20c(); 


 



function parseStateChangeVis(){


	var history = History.getState();

	if (history.hash.search(/\?person=/) > -1){

		var person = history.hash.split('?person=')[1];
		//trim off the suid that the library attaches if we need to. hacky
		if (person.search(/_suid=/)>-1){
			person = person.split('&_suid=')[0]
		}

			//lookup that nice name for the uri
		usePerson = jQuery.map(idLookup, function(obj,index) {
		    if(obj === person)
		         return index;
	})[0];


		changeVisMode("person");

	}else if (history.hash.search(/\?mode=/) > -1){

		var mode = history.hash.split('?mode=')[1];
		//sometime this id gets append to the url
		if (mode.search(/_suid=/)>-1){
			mode = mode.split('&_suid=')[0]
		}
		changeVisMode(mode);

	}else{
		showSpinner("Rendering<br>Network");
		filter();
	}



}



 
function initalizeNetwork(){
 	$("#dynamicListHolder, #dynamicSearchHolder, #dynamicClear").css("display","none")

	 $("#video").css("left","0px");
	 
	 
	 
	if (visMode=="wave"){
		networkGravity =  0.5;
		netwokrLinkLength = 25;
		networkLargeNodeLimit = 20;	
		netwokrCharge = -600;	
		networkMinEdges = 2;	
		networkStopTick = true;
		networkNodeDrag = false;		
		
 	}
	
	if (visMode=="free"){
		networkGravity =  0.1;
		netwokrLinkLength = 25;
		networkLargeNodeLimit = 20;	
		netwokrCharge = -45;		
		networkMinEdges = 2;
		networkStopTick = true;
		networkNodeDrag = false;				
		//scale=0.6;
		//trans=[visWidth/6,visHeight/6];
	}	
	
	if (visMode=="person"){
		networkGravity =  0.1;
		netwokrLinkLength = 55;
		networkLargeNodeLimit = 20;	
		netwokrCharge = -2600;	 
		networkStopTick = false;
		networkNodeDrag = true;				
	}	
	
	if (visMode=="clique"){
		networkGravity =  0.1;
		netwokrLinkLength = 125;
		networkLargeNodeLimit = 20;	
		netwokrCharge = -1500;		
		networkMinEdges = 4;
		networkStopTick = true;
		networkNodeDrag = false;				
	}		
	
	if (visMode=="dynamic"){
		networkGravity =  0.05;
		netwokrLinkLength = 500;
		networkLargeNodeLimit = 20;	
		netwokrCharge = -800;	 
		networkStopTick = false;
		networkNodeDrag = true;		

		//if we have not yet built the dynamic list
		if ($("#dynamicListHolder").length<2){
			//get dynamic list ready
			buildDynamicList();
		}
		
		 $("#video").css("left","225px");
		
		
		$("#dynamicListHolder, #dynamicSearchHolder").css("display","block")
		
		//show a hint 
		if (dynamicPeople.length==0){

			$("#dynamicHelp").fadeIn(10,function(){
				
				$("#dynamicHelp").fadeOut(5000);
				
			})
		}else{
			
			$("#dynamicClear").fadeIn(5000);	
		}
		
		
		
					
	}		


	//if it has already been defined
	if (force == null){		
		force = d3.layout.force()
		.size([$("#network").width() - 5, $("#network").height() - 5]);	 	
			
	}
	
	
	force.gravity(networkGravity);
	force.linkStrength(function(d) {  return linkStrength(d);});
	force.distance(netwokrLinkLength);
	force.charge(netwokrCharge);
	 
	
	
 	if (vis==null){ 

		zoom = d3.behavior.zoom()
			.translate([0,0])
			.scale(0.99)
			.scaleExtent([0.25,6])	//how far it can zoom out and in
			.on("zoom", redraw);	
		
 		vis = d3.select("#network").append("svg:svg") 
			.attr("width", $("#network").width() - 10)
			.attr("height", $("#network").height() - 10)
			.append('svg:g')
			.call(zoom)//.call(d3.behavior.zoom().scaleExtent([0.25, 6]).on("zoom", redraw)) //.call(d3.behavior.zoom().on("zoom", redraw))			
			.append('svg:g');	
	
		
		vis.append('svg:rect')
			.attr('width', $("#network").width() + 1000)
			.attr('height', $("#network").height() + 1000)
			.attr('fill', 'white')
			.attr('id', 'zoomCanvas')
			.style("cursor",  "url(menu/openhand.png)")
			.on("mousedown", function(){
			
				//the grabbing css rules do not work with web-kit, so specifiy the cursor hand and use the css for firefox.
				d3.select("#zoomCanvas").style("cursor",  "url(menu/closedhand.png)");
				d3.select("#zoomCanvas").attr("class","grabbing");
				
			})
			.on("mouseup", function(){
			
				d3.select("#zoomCanvas").style("cursor",  "url(menu/openhand.png)");
				d3.select("#zoomCanvas").attr("class","");
					
				
				
			});	

	}
	
	vis.attr("transform",
	  "translate(" + trans + ")"
	  + " scale(" + scale + ")");   
	
}

//process the triple data through the RDF jquery plugin to create an object
function buildTripleStore(data){
	        console.log(typeof data);
            console.log(JSON.stringify(data));
		tripleStore = $.rdf.databank([],
		  { base: 'http://www.dbpedia.org/',
			namespaces: { 
			  dc: 'http://purl.org/dc/elements/1.1/', 
			  foaf: 'http://xmlns.com/foaf/0.1/', 
			  lj: 'http://www.linkedjazz.org/lj/' } });	  
		
		
		//I'm only intrested in the knowsOf right now before we work more on verifying the 52nd street stuff, so just make all relationships knowsof
		var alreadyKnows = [];


		/***********
		* 	The file we are loading is expected to be a triple store in the format '<object> <predicate> <object> .\n'
		*   Note the space after the final object and the '.' and the \n only
		************/	  
		var triples = data;
		for (x in triples){			
			if (triples[x].length > 0){		
				try{		

					//I'm only intrested in the knowsOf right now before we work more on verifying the 52nd street stuff, so just make all relationships knowsof
					var hash = triples[x].split("> <")[0] + triples[x].split("> <")[2];



					//only add it once
					if (alreadyKnows.indexOf(hash) === -1){

						var newKnowsOf = triples[x].split("> <")[0] + "> <http://purl.org/vocab/relationship/knowsOf> <" + triples[x].split("> <")[2];
						alreadyKnows.push(hash);

						//console.log(newKnowsOf);
						tripleStore.add(newKnowsOf);
						//tripleStore.add(triples[x]);
				


					}
					



				}


				catch(err){
 					//if it cannot load one of the triples it is not a total failure, keep going
					console.log('There was an error processing the data file:');
					console.log(err);										
				}
			}
		}

 
		tripleObject =   data;


		console.log(alreadyKnows.length);
	
	
}

//process the triple data through the RDF jquery plugin to create an object
function buildDescriptionStore(data){
	
		var descStore = $.rdf.databank([],
		  { base: 'http://www.dbpedia.org/',
			namespaces: { 
			  dc: 'http://purl.org/dc/elements/1.1/', 
			  wc: 'http://www.w3.org/2000/01/rdf-schema', 
			  lj: 'http://www.linkedjazz.org/lj/' } });	  
		
		
		/***********
		* 	The file we are loading is expected to be a triple dump in the format '<object> <predicate> <object> .\n'
		*   Note the space after the final object and the '.' and the \n only
		************/	  
		var triples = data.split("\n");
		for (x in triples){			
			if (triples[x].length > 0){		
				try{		
					descStore.add(triples[x]);
				}
				catch(err){
 					//if it cannot load one of the triples it is not a total failure, keep going
					console.log('There was an error processing the data file:');
					console.log(err);										
				}
			}
		}

 
		   descObject = {"http://dbpedia.org/resource/Chuck_Andrus":{"http://dbpedia.org/ontology/abstract":[{"type":"literal","value":"Chuck Andrus (November 17, 1928 \\u2013 October 10, 199William D. Simone7) was an American jazz double-bassist. Andrus was raised in New England and studied at the Manhattan School of Music. In the late 1940s he formed his own ensemble in Springfield, Massachusetts which included Sal Salvador and Phil Woods. He played with Charlie Barnet in 1953, then with Claude Thornhill through the middle of the decade. While with Thornhill he met Terry Gibbs, and the two frequently played and recorded together in subsequent years. As a freelance musician in New York, Andrus worked with Don Stratton, Bernard Peiffer, and Jim Chapin; he also recorded extensively with Woody Herman. One of the most surprising moments of his life came when he went to see a new movie that he hadn't heard about. It was The Wrong Man, a true story starring Henry Fonda. The movie opened with the protagonist, a bass player, leaving his gig late at night at the Stork Club with his double-bass in tow. He then walked down the dark streets to the subway, rode out to Queens, then walked to his apartment. The reason this freaked Chuck out was that he had just recently started at the Stork Cub, replacing the guy who he later discovered had replaced the Wrong Man. Not only that, but Chuck took the same subway every night he worked, to the same stop in Queens, and remarkably, walked by the same block where the other bassist had lived.","lang":"en"}],"http://xmlns.com/foaf/0.1/name":[{"type":"literal","value":"Chuck Andrus","lang":"en"}]}}		
		 
	
	
}

//process the triple data through the RDF jquery plugin to create an object
function buildNameStore(data){
	
		var nameStore = $.rdf.databank([],
		  { base: 'http://www.dbpedia.org/',
			namespaces: { 
			  dc: 'http://purl.org/dc/elements/1.1/', 
			  wc: 'http://www.w3.org/2000/01/rdf-schema', 
			  lj: 'http://www.linkedjazz.org/lj/' } });	  
		
		
		/***********
		* 	The file we are loading is expected to be a triple dump in the format '<object> <predicate> <object> .\n'
		*   Note the space after the final object and the '.' and the \n only
		************/	  
		var triples = data.split("\n");
		for (x in triples){			
			if (triples[x].length > 0){		
				try{		
					nameStore.add(triples[x]);
				}
				catch(err){
 					//if it cannot load one of the triples it is not a total failure, keep going
					console.log('There was an error processing the data file:');
					console.log(err);										
				}
			}
		}

 
	nameObject = {};	
		 
	
	
}

function dataAnalysis(){

	//we need to know some stats about the people before we start to render the network
	//find out the largest nodes
	var totalConnections = 0;
	for (x in tripleObject){	//each x here is a person
		
		var size = 0;
		for (y in tripleObject[x]){		//this level is the types of relations, mentions, knows, etc. each y here is a realtion bundle
			size = size + tripleObject[x][y].length;
		}		
		
		var sizeObj = {}; 
		sizeObj.node = x;			
		sizeObj.size = size;		
		sizeObj.random = Math.floor((Math.random()*100)+1);			
		largestNodes.push(sizeObj);
		totalConnections = totalConnections + size;
	}
	
	
	 
	//now an array of objects of with the .node property being the index to the tripleObect
	largestNodes.sort(function(a,b) {
		return b.size - a.size;
	});	
	
	
	//find out the range of number of connections to color our edges
	edgesAvg = Math.floor(totalConnections/largestNodes.length);
	edgesInterval = (largestNodes[0].size - edgesAvg) / 3;  
	console.log(edgesInterval);
	
	
	var flipFlop = 0;
	//for (largeNode in largestNodes){
	//	largestNodes[largeNode].flipFlop =  (flipFlop % 2 == 1) ?  (flipFlop*-1) : (flipFlop);
	for (var i = largestNodes.length - 1; i >= 0; i--) {		
		largestNodes[i].flipFlop =  (flipFlop % 2 == 1) ?  (flipFlop*-1) : (flipFlop);	
		flipFlop++;
	}		 
	largestNodes.splice(networkLargeNodeLimit,largestNodes.length-networkLargeNodeLimit); 
	largestNodes.sort(function(a,b) {
		return b.flipFlop - a.flipFlop;
	});			
	
	
	if (visMode=="wave"){
	
		//we want to pin some of the larger nodes to the outside in order to keep things readable, so figure our where to put them and store it in this obj array
		for (n in largestNodes){			
				var nudge = 0;
				var r = visHeight/2.5;
				var a = (186 / largestNodes.length) * n;
				
				if (n==0){nudge = 50;}
				if (n==1){nudge = -50;}
		
				largestNodes[n].x = (visWidth/2) + (r+visWidth/4) * Math.cos(a);
				largestNodes[n].y = (visHeight/2) + nudge - 10 + r * Math.sin(a);		
						
			/*	
			 
				vis.append("circle")
						.attr("class", "node")
						.attr("cx", largestNodes[n].x)
						.attr("cy", largestNodes[n].y)
						.attr("r", 8)
						.style("fill", function(d, i) { return fill(i & 3); })
						.style("stroke", function(d, i) { return d3.rgb(fill(i & 3)).darker(2); })
						.style("stroke-width", 1.5);
			
				*/
				
		} 
	}
	
	

	
	  
}


//	Builds the base nodes and links arrays 
function buildBase(){
	 
	
	var allObjects = [];	 
	var quickLookup = {};

	//we need to establish the nodes and links
	//we do it by making a string array and adding their ids to it, if it is unique in the string array then we can add the object to the node array
	
	    
	for (x in tripleObject){	//each x here is a person
	
		console.log('xxxxxx') 
		if (allObjects.indexOf(String(x))==-1){
			allObjects.push(String(x));
			baseNodes.push({id: String(x)});
		}
				console.log( tripleObject ) 

		for (y in tripleObject[x]){		//this level is the types of relations, mentions, knows, etc. each y here is a realtion bundle
			for (z in tripleObject[x][y]){	//here each z is a relation	
                if(tripleObject[x][y][z].value != undefined )	{		
				if (allObjects.indexOf(tripleObject[x][y][z].value)==-1){ 
                    console.log( x);
					console.log( tripleObject[x]); 
					console.log( y);
                    console.log( tripleObject[x][y]);
					console.log( z); 
                    console.log( tripleObject[x][y][z]);
					console.log( tripleObject[x][y][z].value);

					baseNodes.push({id: tripleObject[x][y][z].value});
					allObjects.push(tripleObject[x][y][z].value);
					 
					//we are adding props to this object to store their # of connections, depending on the order they may have already been added if they
					//were added by the creatLink function, so in both places check for the propery and add it in if it is not yet set
					
					if (!connectionCounter.hasOwnProperty(tripleObject[x][y][z].value)){
						connectionCounter[tripleObject[x][y][z].value] = 0;	
					} 

					if (!quickLookup.hasOwnProperty(tripleObject[x][y][z].value)){
						quickLookup[tripleObject[x][y][z].value] = -1;	
					} 
					  
				}
				  
				createLink(String(x),tripleObject[x][y][z].value);
				}
			}
		} 
	} 		
	 
	//asign the number of connections each node has  and add the label	
	for (aNode=0; aNode < baseNodes.length;aNode++){	

         console.log(baseNodes)	
		          console.log(baseNodes[aNode])	

		baseNodes[aNode].connections = connectionCounter[baseNodes[aNode].id];	
		if (baseNodes[aNode].connections>largestConnection){largestConnection=baseNodes[aNode].connections;}	
		
		//build an human label
		var id = baseNodes[aNode].id;
		var label = "";

		if (nameObject.hasOwnProperty(id)){

			if (nameObject[id]['http://xmlns.com/foaf/0.1/name']){
				label = nameObject[id]['http://xmlns.com/foaf/0.1/name'][0].value;
			}
		}

		if (label == ""){
			label = nodeNameMap[baseNodes[aNode].id] 
			 

		}

		 


		baseNodes[aNode].label = label;		
		
		
		
		
		//baseNodes[aNode].labelLast = lastLabel;	
	}	
	
	 
	//we are building the similarity index here, basiclly it loops through all of the people and compairs their connections with everyone else
	//people who have similar connections have larger  simlarityIndex = the # of connections	 
	for (var key in connectionIndex) {	
		var tmpAry = [];		
		if (connectionIndex[key].length > 1){		
			for (var key2 in connectionIndex) {						
				if (key != key2){					
					if (connectionIndex[key2].length > 1){
						var tmpCount = 0;						
						tmpCount =  connectionIndex[key].filter(function(i) {return !(connectionIndex[key2].indexOf(i) == -1);}).length;
						if (tmpCount>1){
							tmpAry.push({name:key2,count:tmpCount})
							if (tmpCount>largestSimilarity){largestSimilarity=tmpCount;}
						}
					}
				}			 
			}
		}
		tmpAry.sort(function(a,b) { 
			return b.count - a.count;
		});			
		 
		simlarityIndex[key] = {}; 
		
		for (x in tmpAry){			 
			simlarityIndex[key][tmpAry[x].name]=tmpAry[x].count;
		}
		
		
		
		
	}		
 
		
			
	function createLink(id1, id2){	
		var obj1 = null, obj2 = null;		
		
		//in an effor to speed this lookup a little is to see if we have indexed the pos of the requested ids already, if so do not loop		
		if (quickLookup[id1]>-1 && quickLookup[id2]>-1){			
			obj1 = quickLookup[id1];
			obj2 = quickLookup[id2];			
  		}else{
			//not yet in the quicklookup object, it will be added here	
			for (q in baseNodes){
				if (baseNodes[q].id == id1){obj1 = q;}
				if (baseNodes[q].id == id2){obj2 = q;}
				if (obj1!=null&&obj2!=null){
					
				 
					quickLookup[id1] = obj1;
					quickLookup[id2] = obj2;				
					
					break;
				}	
			}
					
		}
		
		var customClass = "link_" + id1.split("/")[id1.split("/").length-1].replace(cssSafe,''); 
		customClass = customClass + " link_" + id2.split("/")[id2.split("/").length-1].replace(cssSafe,''); 
		
		baseLinks.push({source: baseNodes[obj1], target: baseNodes[obj2], distance: 5, customClass:customClass});
		
		//+1 the number of conenctions, of it is not yet in the object, add it at 1
		if (!connectionCounter.hasOwnProperty(id1)){
			connectionCounter[id1] = 1;
		}else{
			connectionCounter[id1] = connectionCounter[id1] + 1;
		}
		if (!connectionCounter.hasOwnProperty(id2)){
			connectionCounter[id2] = 1;
		}else{
			connectionCounter[id2] = connectionCounter[id2] + 1;
		}		
		 	
			
		//add this relation ship to the connectionIndex object
		//has propery yet?
		if (!connectionIndex.hasOwnProperty(id1)){
			connectionIndex[id1] = [];
		}		
		if (!connectionIndex.hasOwnProperty(id2)){
			connectionIndex[id2] = [];
		}				
		
		//does it have this relationship already?
		if (connectionIndex[id1].indexOf(id2) == -1){
			connectionIndex[id1].push(id2);	
		}	
		if (connectionIndex[id2].indexOf(id1) == -1){
			connectionIndex[id2].push(id1);	
		}
	
			
		
				
	}	
	
	 
	
	
}


function filter(clear){
	
	 
	
	if (typeof clear == 'undefined'){clear = true;}
 	  
	//are we wiping the nodes out or just adding?
	
	
	if (clear){
		
		$("#network").css("visibility","hidden");		
		vis.selectAll("g.node").remove(); 
		vis.selectAll("line.link").remove();

		
		nodes=[];
		links=[]; 
		force.nodes([]);
		force.links([]);
		restart();
	}
			 
	 
	var workingNodes = [];
	var workingLinks = [];
	 
	
	
	nodesRemove = {}; 
	
	if (visMode == 'person'){
	
		for (var key in connectionIndex) {		
			if (connectionIndex[key].indexOf(usePerson)==-1 && key != usePerson){				
				nodesRemove[key]=true;	
			}
		}
		
	}else if(visMode == 'dynamic'){
		
		console.log(dynamicPeople);
		
		var connected = [];
		var connetedCounteed = {};
				
		//we want to only add people if they are a selected person, or they have a connection that is shared by at least one person aready on the graph		
				
		for (x in dynamicPeople){
		
			//add everyones connections
			for (y in connectionIndex[dynamicPeople[x]]){
					connected.push(connectionIndex[dynamicPeople[x]][y]);
			}
			
		}
		
		for (x in connected){
			
			if (connetedCounteed.hasOwnProperty(connected[x])){
				connetedCounteed[connected[x]] = connetedCounteed[connected[x]] + 1;
			}else{
				connetedCounteed[connected[x]] = 1;
			}
				
		}
		
		console.log(connetedCounteed);
		
		
		for (x in baseNodes){
		
		
			//is this node in the conenctions?
			if (connetedCounteed.hasOwnProperty(baseNodes[x].id)){
				
				//yes, but do they have more than one entry, meaning that more than 1 person has them as a connection?
				if (connetedCounteed[baseNodes[x].id] < 2){
					
					//no
					//but are they one of the dynamic people?
					if (dynamicPeople.indexOf(baseNodes[x].id)==-1){					
						//no
						nodesRemove[baseNodes[x].id]=true;	
					}
					
				}
				
				
			}else{
				
				//no...but are they the person themselfs?
				if (dynamicPeople.indexOf(baseNodes[x].id)==-1){
					//no, remove them
					nodesRemove[baseNodes[x].id]=true;					
				}
			
				
			}
			
			 
			
			
			
			
		}
		
				
	 
 
	}else{
		
		
		
		//filter out people with too little number of conenctions. we use the connectionCounter from the buildBase function		
		for (var key in connectionCounter) {
		  if (connectionCounter.hasOwnProperty(key)) { 
			if (connectionCounter[key] < networkMinEdges){
				nodesRemove[key]=true;
			} 
		  }
		}		
		 
		
	 	 
		
		
		
	}
	

	//now build the working arrays of the things we want to keep, 
	for (aNode in baseNodes){
		if (!nodesRemove.hasOwnProperty(baseNodes[aNode].id)){
			workingNodes.push(baseNodes[aNode]);
		}
	}
	
	console.log(workingLinks);
	for (aLink=0;aLink< baseLinks.length ; aLink++){		
		if (  nodesRemove.hasOwnProperty(baseLinks[aLink].source.id) == false && nodesRemove.hasOwnProperty(baseLinks[aLink].target.id) == false){
			workingLinks.push(baseLinks[aLink]);
		}
	}
 
	console.log(workingLinks);
	
	if(visMode == 'dynamic'){		
		//for the dynmaic mode, we don't want a whole mess of edges cofusing things, since we are just intrested in how the added people are connected
		var temp = []; 
		for (aLink in workingLinks){			
			if (dynamicPeople.indexOf(workingLinks[aLink].source.id) != -1 || dynamicPeople.indexOf(workingLinks[aLink].target.id) != -1){
				temp.push(workingLinks[aLink]);
			}					
		}		
		workingLinks = temp;
  
	} 


	/*
	
	for (var i = nodesRemove.length - 1; i >= 0; i--) {	
		nodes.splice(nodesRemove[i],1);
	}
	for (var i = linksRemove.length - 1; i >= 0; i--) {	
		links.splice(linksRemove[i],1);
	}
	*/	
	
	 

	//lock the large nodes to the pattern 
	for (aNode in workingNodes){

		workingNodes[aNode].lock = false; 
		workingNodes[aNode].y = visHeight / 2;
		workingNodes[aNode].x = Math.floor((Math.random()*visWidth)+1);
		
		
		if (visMode != "person"){
			for (large in largestNodes){
				if (largestNodes[large].node == workingNodes[aNode].id){
					workingNodes[aNode].lockX = largestNodes[large].x;
					workingNodes[aNode].lockY = largestNodes[large].y;				
					workingNodes[aNode].lock = true; 
				}			
			}
		}
		
		if (visMode=="person" && workingNodes[aNode].id == usePerson){
			usePersonIndex = aNode;
		}
		
 
	}	
	
	
	//copy over our work into the d3 node/link array
	nodes = force.nodes();
	links = force.links();		 
	
	for (aNode in workingNodes){
		nodes.push(workingNodes[aNode]);
	}
	for (aLink in workingLinks){
		links.push(workingLinks[aLink]);
	}		
	
	
	/*
	if(visMode == 'dynamic'){		
		//we also dont want to double add nodes, we needed to leave them in up to this point so the new links could be drawn, but, now take them out
		var temp = [];
		for (r in nodes){
		
			var add=true;
		
			//is it already in there?
			for (n in temp){
				if (nodes[r].id == temp[n].id){
					add=false;
				}
			}
		
			if (add){
				temp.push(nodes[r]);
			}		
			
		}		
		nodes = temp;
		
		
		
	} 	
	
	
	console.log(nodes);
	*/
	
	 
	restart(); 
	
	 
	
	
	
	
}


function restart(){
 	
		
	 vis.append("svg:defs").selectAll("marker")
	.data(["FOAFknows"])
  .enter().append("svg:marker")
	.attr("id", String)
	.attr("class","marker")
	.attr("viewBox", "0 -5 10 10")
	.attr("refX", 10)
	.attr("refY", 0)
	.attr("markerWidth", 10)
	.attr("markerHeight", 10)
	.attr("orient", "auto")
  .append("svg:path")
	.attr("d", "M0,-5L10,0L0,5")
	.style("fill","#666")
	.style("stroke-width",0);	

	vis.selectAll("line.link")
	  .data(links)
	.enter().insert("line", "circle.node")
	  .style("stroke",function(d){return edgeColor(d);}) 
	  .style("stroke-width",function(d){return edgeStrokeWidth(d);}) 	  
	  .attr("class", function(d){return "link " + d.customClass})
	  .attr("marker-end", function(d) { return  (visMode=="person"||visMode=="dynamic") ? "url(#FOAFknows)" : "none"; })
	  .attr("x1", function(d) { return d.source.x; })
	  .attr("y1", function(d) { return d.source.y; })
	  .attr("x2", function(d) { return d.target.x; })
	  .attr("y2", function(d) { return d.target.y; }); 
	
	
	
	  
	var node = vis.selectAll("g.node")
	  .data(nodes);
	  
	var nodeEnter = node.enter().append("svg:g")
	  .attr("class", "node")
	  .style("cursor","pointer") 
	  .attr("id", function(d){  return "node_" + d.id})
	  .on("mouseover",function(d){
    		    currentNode = d; 
				showPopup(d);	
				
		}).on("mouseout",function(d){
	

			currentNode = d;
			hidePopup(d); 	
			 
		}).on("click",function(d){
	 
			hidePopup();
			  usePerson = d.id;  
			 $("#network").fadeOut('fast',
			 	 function(d) {
					   
					 
					 changeVisMode("person");  
					 
				 }	  
			 );
			
		});	 
		
	if (networkNodeDrag){
		nodeEnter.call(force.drag);	
	}
	
	
	
	
		  	
	  
 	nodeEnter.append("circle") 
		.attr("id", function(d){return "backgroundCircle_" + d.id})
		.attr("class","backgroundCircle")
		.attr("cx", function(d) { return 0; })
		.attr("cy", function(d) { return 0; }) 
		.attr("r", function(d) { return  returnNodeSize(d); })
		.style("fill", function(d, i) { return "#ccc"; }) //return fill(i & 3); })
		.style("stroke", function(d, i) { return returnNodeColor(d); })
		.style("stroke-width", function(d){return returnNodeStrokeWidth(d);});
	
	nodeEnter.append("svg:image") 
		  .attr("id", function(d){  return "imageCircle_" + d.id.split("/")[d.id.split("/").length-1].replace(cssSafe,'')})
		  .attr("class","imageCircle")
		  .attr("xlink:href", function(d){  
		       if(nodeDetailsMap[d.id] == undefined )
			   return "";
			  if(nodeDetailsMap[d.id].nodeType == "Decision")
			  return decisionIconUrl ;
			  if(nodeDetailsMap[d.id].nodeType == "Plan")
			  return  planIconUrl ;

		  })
   		  .attr("x", function(d) { return  (returnNodeSize(d)*-1); })
		  .attr("y", function(d) { return  (returnNodeSize(d)*-1); })
		  .attr("width", function(d) { return  (returnNodeSize(d)*2); })
		  .attr("height", function(d) { return  (returnNodeSize(d)*2); });
	   
 
 
 	nodeEnter.append("svg:text") 
  	  .attr("id", function(d){  return "circleText_" + d.id})
      .attr("font-size", function(d){return (returnNodeSize(d) / (1.1))})
	  .attr("class",  function(d){return "circleText"})
	  .attr("font-family", "helvetica, sans-serif")  
	  .attr("text-anchor","middle") 
	 // .attr("display",function(d){ return displayLabel(d);})
	  .attr("x", function(d) { return  (returnNodeSize(d)*-0.1); }) 
	  .attr("y", function(d) { return returnNodeSize(d)+returnNodeSize(d)/1.2; }) 
	  .text(function(d){  var dlable =  ((d.label.length > 10) ? ( d.label.substring(0, 9)+'..'):  (  d.label));  return dlable;   });  		  
 
	
	force.start();	



	//controls the movement of the nodes	
	force.on("tick", function(e) {
		
		if (visMode=="wave"){
			for (aNode in nodes){
				if (nodes[aNode].lock){
					nodes[aNode].x = nodes[aNode].lockX;
					nodes[aNode].y = nodes[aNode].lockY; 
				}else{
					if (e.alpha<=.08){
						if 	(nodes[aNode].y <= 0){nodes[aNode].y = Math.floor((Math.random()*20)+8); nodes[aNode].lock = true; nodes[aNode].lockY = nodes[aNode].y; nodes[aNode].lockX = nodes[aNode].x; }
						if 	(nodes[aNode].y >= visHeight){nodes[aNode].y = visHeight- Math.floor((Math.random()*60)+20); nodes[aNode].lock = true; nodes[aNode].lockY = nodes[aNode].y; nodes[aNode].lockX = nodes[aNode].x; }				
					}
				}
			}
			
		}
	 
 		if (visMode=="person"){
		    console.log(nodes);
			console.log(usePersonIndex)
			console.log(nodes[usePersonIndex]	)

			nodes[usePersonIndex].x = visWidth/2;
			nodes[usePersonIndex].y = visHeight/2;				
		}
		
		
		if (networkStopTick){
				
			if (e.alpha<=.02){
				hideSpinner();
				 
					
				vis.selectAll("line.link")
				  .attr("x1", function(d) { return d.source.x; })
				  .attr("y1", function(d) { return d.source.y; })
				  .attr("x2", function(d) { return d.target.x; })
				  .attr("y2", function(d) { return d.target.y; });
	 
					
				vis.selectAll("g.node").attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")";}); 
				
				
				if ($("#network").css("visibility") != "visible"){
					$("#network").css("visibility","visible");
					$("#network").fadeIn();
					$("#zoomWidget").css("visibility","visible");
				}
				
				if (networkStopTick){			
					force.stop();	  
				}
				 
				
			}
						
			
		}else{
			 
			hideSpinner();

		
  
			//in this mode (don't stop tick) is used by the person and dynamic mode, we ewant to illustrat the flow of relationships, so 
			//do the math needed to draw the markers on the outside of the nodes.
			//for the other modes, its not important	
			vis.selectAll("line.link")
			  .attr("x1", function(d) { return pointsBetween(d.source,d.target)[0][0]; })
			  .attr("y1", function(d) { return pointsBetween(d.source,d.target)[0][1]; })
			  .attr("x2", function(d) { return pointsBetween(d.source,d.target)[1][0];})
			  .attr("y2", function(d) { return pointsBetween(d.source,d.target)[1][1]; });
								
				 
		
			vis.selectAll("g.node").attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")";}); 
		
			if ($("#network").css("visibility") != "visible"){
				$("#network").css("visibility","visible");
				$("#network").fadeIn();
				$("#zoomWidget").css("visibility","visible");
			}
				 
							
		}
		
		 		

		 
		
	});			
	
}

	function displayLabel(d){
	
		if (visMode=="person" || visMode == "dynamic"){
			return "block";	
		}else{
			return (d.connections >= edgesInterval/1.5) ? "block" : "none";
		}
		
	}

	function returnNodeStrokeWidth(d){

		if (visMode == "person" || visMode == "dynamic"){
			
			if (dynamicPeople.indexOf(d.id) != -1 || usePerson == d.id){
				
				return 5;				
			}
			
			
		}
		
		return 1.5	
		
	}

	function returnNodeColor(d){
	
		if (visMode == "person" || visMode == "dynamic"){
			
			if (dynamicPeople.indexOf(d.id) != -1 || usePerson == d.id){
				
				return "#FC0";				
			}
			
			
		}
		
		return "#666"
			
	}

	function returnNodeSize(d){
	    return 10;
		if (visMode=="person"){
		
			if (d.id == usePerson){
				return 50;	
			}else{
				return 15 + Math.round(d.connections/15);
			} 
		}else if (visMode == "dynamic"){
			
			if (dynamicPeople.indexOf(d.id)==-1){
				return 20;	
			}else{
				return 35;
			}  
			
		}else{
		    var radius = Math.round(Math.sqrt(d.connections) + (d.connections/6)); 
			if( radius < 10 )	 
			radius = 10;
			if( radius > 30 )
			radius = 30;  
			return  radius;
				
		}
		
		
	}
 
 

//wooo!, from https://groups.google.com/forum/?fromgroups#!topic/d3-js/ndyvibO7wDA
function pointsBetween(circle1,circle2,standOff1,standOff2){
  var x1=circle1.x, y1=circle1.y,
      x2=circle2.x, y2=circle2.y,
      dx=x2-x1,                    dy=y2-y1,
      r1=returnNodeSize(circle1) + (standOff1||0),
      r2=returnNodeSize(circle2) + (standOff2||0);
  if ( (r1+r2)*(r1+r2) >= dx*dx+dy*dy ) return [[0,0],[0,0]];
  var a=Math.atan2(dy,dx), c=Math.cos(a), s=Math.sin(a);
  return [
    [x1+c*r1,y1+s*r1],
    [x2-c*r2,y2-s*r2]
  ];
}



function hidePopup(d){


	//hidePopupTimer
	jQuery("#popUp").css("display","none");
    
	var customClass = "link_" + currentNode.id;   	

	d3.selectAll(".marker").attr("stroke-opacity",1).attr("fill-opacity",1)
	d3.selectAll(".link").attr("stroke-opacity",1).style("fill-opacity",1).style("stroke-width",function(d){return edgeStrokeWidth(d)});
	d3.selectAll(".backgroundCircle").attr("fill-opacity",1).attr("stroke-opacity",1);			
	d3.selectAll(".imageCircle").attr("display","block");
	d3.selectAll(".circleText").attr("fill-opacity",1).attr("stroke-opacity",1);			
    var dlable =  ((d.label.length > 10) ? ( d.label.substring(0, 9)+'..'):  (  d.label));   

    d3.selectAll("#circleText_"+ d.id).text( dlable );	   			

	
	
}

function showPopup(d,cords){ 
	  
    
	clearTimeout(hidePopupTimer);
	d3.selectAll(".link").attr("stroke-opacity",0.1).attr("fill-opacity",0.1);			
	d3.selectAll(".backgroundCircle").attr("fill-opacity",0.1).attr("stroke-opacity",0.1);			
	d3.selectAll(".circleText").attr("fill-opacity",0.1).attr("stroke-opacity",0.1);						
	d3.selectAll(".imageCircle").attr("display","none");
	
	d3.selectAll(".marker").attr("stroke-opacity",0.1).attr("fill-opacity",0.1)
	
	var customClass =  d.id; 
	//d3.selectAll("." + "link_" + customClass).style("stroke","#fd8d3c").style("stroke-opacity",1).style("fill-opacity",1);//.attr("display","block");//.style("opacity",1);
	d3.selectAll("." + "link_" + customClass).attr("stroke-opacity",1).style("fill-opacity",1).style("stroke-width",2).attr("stroke","#9E3D3D");	;//.style("opacity",1);			
	
	d3.selectAll("#backgroundCircle_" + customClass).attr("fill-opacity",1).attr("stroke-opacity",1);			
	d3.selectAll("#imageCircle_"+ customClass).attr("display","block");
	d3.selectAll("#circleText_"+ customClass).attr("fill-opacity",1).attr("stroke-opacity",1);	
	d3.selectAll("#circleText_"+ customClass).text( d.label);				

	 
     xCord=  d3.event.pageX;
	 yCord = d3.event.pageY;
	
	for (x in connectionIndex[d.id]){
		var id = connectionIndex[d.id][x].split("/")[connectionIndex[d.id][x].split("/").length-1].replace(cssSafe,'');
		
		d3.selectAll("#backgroundCircle_" + id).attr("fill-opacity",1).attr("stroke-opacity",1) 		
		d3.selectAll("#imageCircle_"+ id).attr("display","block");
		d3.selectAll("#circleText_"+ id).attr("fill-opacity",1).attr("stroke-opacity",1);				
			
	}	                $('#popupDecisionCard').css('display','none');
                        $('#popupPlanCard').css('display','none');
                        document.getElementById("cardBottomDecision").style.display="none";
                        document.getElementById("dropBtnDecision").style.backgroundPosition="-64px -8px"; 
                        
                        document.getElementById("cardBottomPlan").style.display="none";
                        document.getElementById("dropBtnPlan").style.backgroundPosition="-64px -8px"; 
                        
                        if(document.getElementById("colorDiv")!=null){
                                        document.getElementById("colorDiv").style.display="none";
                                        document.getElementById("colorDivCurve").style.display="block"; 
                        }
                       // for decision node set the details
						var record = nodeDetailsMap[d.id]
						lastMouseOn = d.id;

						if(record.nodeType == "Decision")
						{
										   
						    $('#namelinkDecision').text(record.nodeName);
						    $('#namelinkDecision').attr('href','/'+record.id);
						  
						    $('#duedate').text(record.deadlineNum ); 
						    $('#duedate').attr('style', ( record.deadlineState=='Positive'? 'color:#66B02D':'color:#FF3C03'  ) )
						   
						    $('#status').text(record.status)
						    $('#colorDivCurve').attr('style','background-color:'+record.statusColor)
						  
						    $('#phase').text(record.phases);
						   
						    $('#mystance').text(record.stanceApprovalStatus == null ? '':record.stanceApprovalStatus);
						   
						    $('#mystanceColorDiv').attr('style','background-color:#'+record.stanceApprovalStatusColor);
						   
						   
						    $('#a-block').attr('style', (record.Accountable ? 'background-color:'+ record.AccountableRoleColor :'background-color:#d9d9d9'));
						    $('#r-block').attr('style', (record.Responsible ? 'background-color:'+ record.ResponsibleRoleColor :'background-color:#d9d9d9'));
						    $('#c-block').attr('style', (record.Consulted ? 'background-color:'+ record.ConsultedRoleColor :'background-color:#d9d9d9'));
						    $('#i-block').attr('style', (record.Informed ? 'background-color:'+ record.InformedRoleColor :'background-color:#d9d9d9'));
						    $('#b-block').attr('style', (record.Backup ? 'background-color:'+ record.BackupRoleColor :'background-color:#d9d9d9'));
						    $('#v-block').attr('style', (record.Veto ? 'background-color:'+ record.VetoRoleColor :'background-color:#d9d9d9'));
		 
						    $('#requestphoto').attr('src',record.ownerPhoto);
						    $('#requestphoto').attr('title',record.OwnerName);
						  
						    $('#decisionby').text( record.OwnerName);
						    $('#decisionbyDept').text( record.ownerDept == null ?'':record.ownerDept);
						   
						    if( record.pendingTaskCount > 0 )
						    $('#taskcount').text(record.pendingTaskCount +' Task Late');
						    else
						    $('#taskcount').css('dispaly','none');
						   
						    $('#averagerelevance').attr('src','/'+record.relevenceImage);
						    $('#rating').text(record.AverageRating);
						  
						  
						    $('#totallikes').text(record.TotalLikes);
						    $('#totaldislikes').text(record.TotalDislikes);  
						   
						    $("#moodimage").css('background-image', 'url(/'+record.moodImage+') ');
						    $("#moodimage").css('backgroundPosition',  record.moodImagePosition  );

						   
						    $('#moodnumber').text(record.moodStatus+'('+record.moodNumber+')');
							if(record.nodeType == "Decision") 
						    $('#popupDecisionCard').css({"display":"block","position":"absolute","top":(yCord),"left":(xCord)});
						   
												   
						}
						if(record.nodeType == "Plan"){
                           lastMouseOn = record.id;
                           $('#namelinkPlan').text(record.nodeName);
                           $('#namelinkPlan').attr('href','/'+record.id);
                           
                           $('#planstart').text(record.startdate ); 
                           $('#planstart').attr('style', ( record.deadlineState =='Positive'? 'color:#66B02D':'color:#FF3C03'  ) )
                           
                            $('#planend').text(record.enddate ); 
                            $('#planend').attr('style', ( record.deadlineState =='Positive'? 'color:#66B02D':'color:#FF3C03'  ) )
                           
                            $('#planlastmodified').text(record.modifieddate ); 
                       
                            $('#location').text(record.location == null?'':record.location ); 
                          
                            $('#itemcount').text(record.itemCount );
                           
                            $('#activities').text(record.activityCount );
                            
                            if( record.dueCount > 0)
                            $('#latetasks').text( '('+record.dueCount+')' );
                            else
                            $('#latetasks').html( '' );  
                           
                            $('#description').text(record.description == null? '' : record.description);  
                           
                            $('#accountablephoto').attr('src',record.accountableImage ); 
                            $('#accountablephoto').attr('title',record.accountableName ); 
                            
                            $('#accountablename').text(record.accountableName ); 
                            $('#accountableDept').text(record.accountableDept == null ? '' :record.accountableDept ); 
							if(record.nodeType == "Plan")
						    $('#popupPlanCard').css({"display":"block","position":"absolute","top":(yCord),"left":(xCord)}); 
                        
                       }
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
    return;
 
	
	var useX,useY;
	
	if (typeof cords != 'undefined'){
		useX=cords[0];
		useY=cords[1];		
	}else{
		
		
		if (scale == 1 && trans[0] == 0 && trans[1] == 0){
			
			useX=d.x;
			useY=d.y;			
			
		}else{
			useX=d3.event.pageX;
			useY=d3.event.pageY;


			
		}
		


		  
		
	}
	

	
	
	var descText = '';	
	if (descObject.hasOwnProperty(d.id)){

		if (descObject[d.id]['http://dbpedia.org/ontology/abstract']){
			var desc = descObject[d.id]['http://dbpedia.org/ontology/abstract'][0].value;
			var r = /\\u([\d\w]{4})/gi;
			desc = desc.replace(r, function (match, grp) {
				return String.fromCharCode(parseInt(grp, 16)); } );
			desc = unescape(desc); 
			descText = decodeURIComponent(desc);
			descText = descText.replace(/&ndash;/gi,'-');
			descText = descText.replace(/&amp;/gi,'&');	

			var link = d.id.replace('dbpedia','wikipedia').replace('resource','wiki');

			descText = descText.substring(0,250) + '...' + '<br>' + '<a class="popup-link" target="_blank" href="' + link + '">From Wikipedia</a><br><br>';	
			

		}else{
			descText = "";
		}

		
	}
	
	
	//if (jQuery("#toolTip .content").html()=="<span>Sorry could not figure out this relationship.</span>"){
	//	return false;	
	//}
	
	var useId = $.trim(decodeURI(d.id).split("\/")[decodeURI(d.id).split("\/").length-1]);
	 
	jQuery("#popUp").empty();
	
	
 	if (fileNames.indexOf(useId+'.png')==-1){	
		var useImage = 'menu/no_image.png';
	}else{
		var useImage = '/image/round/' + useId+'.png'
	}
	
	
	jQuery("#popUp").append(
	
		$("<img>")
			.attr("src", function(){return useImage;})
			.css("height","75px")
			.css("width","75px")
			.css("min-height","75px")
			.css("min-width","75px")
			.css("position","absolute")
			.css("left","0px")
			.css("top","0px")						
			.error(function(){$(this).css("visibility","hidden")})
	).append(
		$("<span>")
			.css("color","#fff")
			.text(d.label)
			.css("position","absolute")
			.css("left","80px")
			.css("top","0px")
				
	).append(
		$("<div>")			 
			.css("font-size","10px")
			.css("width","138px")
			.css("margin-left","80px")
			.css("margin-top","22px")
			.css("min-height","140px")
			.css("text-align","left")
			.attr("id","popupDesc")
			.html(descText)
 
				
	).append(
		$("<div>")

			.css("position","absolute")
			.css("border","solid 1px white")
			.css("border-radius","5px")
			.css("left","20px")
			.css("cursor","pointer")
			.css("top","85px")			
			.css("visibility",function(){
	
				if (metaNames.indexOf(useId+'.meta')==-1){
					return "hidden";			
				}else{
					return 'visible';
				}
				
				
			})			
			.attr("title","Click to play music by " + d.label + ".")
 			.append(
				$("<div>")
					.attr("id","playButton")
					.data("useId",useId)
					.click(function(){
						
						loadYouTube($(this).data("useId"));
						
						
						
					})
			)
  		
	
	
	
	);



	if (visMode == 'person' && nodes[usePersonIndex].label != d.label ){

		var domFragment = $("<div>").addClass('popup-transcript-link-holder');

		domFragment.append(

			$("<div>")
				.addClass('popup-transcript-link-image')
				
		);


		domFragment.append(

			$("<div>")
				.addClass('popup-transcript-link')
				.text("View transcript text about " + d.label + " and " + nodes[usePersonIndex].label)
		);


		domFragment.click(function launchDialogViewer(){
			showDialogPopup(d.id,nodes[usePersonIndex].id);
		});

		domFragment.append($("<br>"));



		$("#popUp").append(domFragment);



	}

	 
	
	//we need to define where to place the box in relation of the node on the vis
	if (useX < visWidth/2){
	
		//is there room to go to the left of the node anyway?
		if (useX-jQuery("#popUp").width() > 0){
			
			useX = useX - jQuery("#popUp").width() - 5;
			
		}else{
			
			useX = useX + 15;		
		}
	
		
 		
	}else{
		
		if (useX+jQuery("#popUp").width()+25 <= visWidth){
			useX = useX + 15;	
		}else{
			useX = useX - jQuery("#popUp").width() - 5;
		}
		
	}
	
	if (useY + jQuery("#popUp").height() > visHeight){
		useY = useY -  jQuery("#popUp").height();
		
		
	}
	
	//the 
	if ($("#video object").length > 0){
		
		
	}
	
	
		
	jQuery("#popUp")
		.css("left", useX + "px")
		.css("top", useY + "px");
 
 	jQuery("#popUp").fadeIn(300);
		 
}


function showDialogPopup(person1,person2){


	jQuery("#popUp").fadeOut(100)


	vex.dialog.open({
	  message: 'Transcript Dialog',
	  input: '<div class="transcript-dialog-holder"></div>',
	  callback: function(data) {
	    if (data === false) { 
	      return console.log('Cancelled');
	    }
	    return false;


	  }
	});

	//max it out
	$(".vex-content").css("width",$(window).width()-100);
	$(".transcript-dialog-holder").css({height: $(window).height()-475});
	$(".vex-dialog-button-secondary").hide();

	


	//load the inital info about these two
	$.get('/api/compare/<' + encodeURIComponent(person1) + '>/<' + encodeURIComponent(person2) + '>', function(realTalk) {

		//load the transcript data for the context
		$.get('/api/text/'+realTalk.transcript, function(transcript) {

			//build the link to the transcript
			$('.vex-content').first().append($("<a>").addClass('transcript-dialog-doc-link').text('Transcript Source').attr('target','_blank').attr('href',transcript.sourceURL));


			//build the summary info from 52nd
			if (realTalk.userBeingTalkedAbout.length != 0 || realTalk.userTalkingAbout.length != 0){

				var all = realTalk.userBeingTalkedAbout.concat(realTalk.userTalkingAbout);
				console.log(all);

				$('.vex-content').first().append(

					$("<div>")
						.addClass('transcript-dialog-holder-semantic')		
						.append($("<span>").html('Semantic data from <a targe="_blank" href="http://linkedjazz.org/52ndStreet/">52nd St Crowd</a>: '))			

				);

				var added=[];

				for (var a in all){

					var rel = all[a];

					var source = rel.source.replace('<','').replace('>','') , target = rel.target.replace('<','').replace('>','') , relationship = "", color = "grey";

					if (nameObject[source]){
						if (nameObject[source]['http://xmlns.com/foaf/0.1/name']){
							source = nameObject[source]['http://xmlns.com/foaf/0.1/name'][0]['value'];
						}
					}

					if (nameObject[target]){
						if (nameObject[target]['http://xmlns.com/foaf/0.1/name']){
							target = nameObject[target]['http://xmlns.com/foaf/0.1/name'][0]['value'];
						}
					}

					if (rel.value == '<http://purl.org/vocab/relationship/influencedBy>'){
						relationship = "influenced by";
						color = 'rgba(188, 143, 102, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/mentorOf>'){
						relationship = "mentored";
						color = 'rgba(229, 142, 60, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/knowsOf>'){
						relationship = "knows of";
						color = 'rgba(131, 149, 159, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/acquaintanceOf>'){
						relationship = "is acquaintance of";
						color = 'rgba(77, 165, 213, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/closeFriendOf>'){
						relationship = "friend of";
						color = 'rgba(43, 175, 247, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/hasMet>'){
						relationship = "has met";
						color = 'rgba(108, 156, 182, 0.25)';
					}else if (rel.value == '<http://purl.org/vocab/relationship/friendOf>'){
						relationship = "friends with";
						color = 'rgba(43, 175, 247, 0.25)';
					}else if (rel.value == '<http://linkedjazz.org/ontology/inBandTogether>'){
						relationship = "was in band together with";
						color = 'rgba(159, 144, 131, 0.25)';
					}else if (rel.value == '<http://linkedjazz.org/ontology/playedTogether>'){
						relationship = "played together with";
						color = 'rgba(159, 144, 131, 0.25)';
					}else if (rel.value == '<http://linkedjazz.org/ontology/bandmember>'){
						relationship = "was bandmember of";
						color = 'rgba(159, 144, 131, 0.25)';
					}else if (rel.value == '<http://linkedjazz.org/ontology/touredWith>'){
						relationship = "toured with";
						color = 'rgba(159, 144, 131, 0.25)';
					}else if (rel.value == '<http://linkedjazz.org/ontology/bandLeaderOf>'){
						relationship = "was band leader of";
						color = 'rgba(159, 144, 131, 0.25)';
					}else if (rel.value == '<http://purl.org/ontology/mo/collaborated_with>'){
						relationship = "collaborated with";
						color = 'rgba(159, 144, 131, 0.25)';
					}



					if (added.indexOf(source + ' ' + relationship + ' ' + target) == -1){

						$('.transcript-dialog-holder-semantic').first().append(

							$("<span>")
								.addClass('transcript-dialog-holder-semantic-label')		
								.html(source + ' ' + relationship + ' ' + target)
								.css("background-color",color)	

						);

						added.push(source + ' ' + relationship + ' ' + target)



					}




				}


			}

			


			var allAddedIds = [];

			//we need to loop through all the occurances
			for (var x in realTalk.occurances){

				var textId = parseInt(realTalk.occurances[x].id);
				var type = realTalk.occurances[x].type;

				if (allAddedIds.indexOf(textId)>-1){
					continue;
				}

				allAddedIds.push(textId);

				if (type == 'A' && textId > 0){
					textId = textId-1 + ',' + textId;
					allAddedIds.push(textId-1);
					console.log(realTalk.occurances[x].type);
				}

				if (type == 'Q'){
					allAddedIds.push(textId+1);
					textId = (textId) + ',' + (textId+1);
					
				}

				$.get('/api/text/'+realTalk.transcript +'/' + textId, function(transcriptText) {


					//it will likely be a pair of responses
					for (t in transcriptText){


						//add the image in
						$('.transcript-dialog-holder').first().append(
							$("<div>")
								.addClass( ( transcriptText[t].type == 'Q'  ) ? 'questionImage' : 'answerImage' )
								.append(
									$("<img>")
										.attr('src',function(){

											var useImage = ""

											if (transcriptText[t].type == 'Q'){
												useImage = '/52new/img/no_image_square.png';
											}else{

												var uri = transcript.intervieweeURI.replace('<','').replace('>','');
												var useId = $.trim(uri.split("\/")[uri.split("\/").length-1]);

									 			if (fileNames.indexOf(useId+'.png')==-1){
													useImage =  "/52new/img/no_image_square.png'";			
												}else{
													useImage =  "/image/round/" + useId+'.png';
												}
											}

											return useImage;
										})
										
								)
								.append(
									$("<span>")
										.text( ( transcriptText[t].type == 'Q'  ) ? 'Interviewer' : transcript.interviewee)

								)
								
						);

						$('.transcript-dialog-holder').first().append(


							$("<div>")
								.html( highlightText(transcriptText[t].text, [person1, person2]) )
								.addClass('bubble')
								.addClass(  ( transcriptText[t].type == 'Q'  ) ? 'question' : 'answer')


						);

						$('.transcript-dialog-holder').append($("<br>").css("clear","both"));
						







					}


					$('.transcript-dialog-holder').append($("<hr>").css("clear","both"));



				});

			}



		});
		




	});



}

function highlightText(text, uris){


	for (var n in uris){

		var uri = uris[n];


		if (nameObject[uri]){
			if (nameObject[uri]['http://xmlns.com/foaf/0.1/name']){

				var name = nameObject[uri]['http://xmlns.com/foaf/0.1/name'][0]['value'];


				var re = new RegExp(name,"gi");

				text = text.replace(re,'<span class="highlight">' + name + '</span>' );

			}
		}

	}

	

	return text;

}

function changeVisMode(changeTo){
    console.log(usePerson);
	if (rendering)
		return false;

	rendering = true;
  
  
	 
       console.log(usePerson);
 	//set the gephi download link
	if (changeTo == 'person'){
	
		$("#gephi").show();
		$("#gephi").attr("href", 'http://linkedjazz.org/api/relationships/ego/%3C' + encodeURIComponent(usePerson) + '%3E/gexf');
	
	}else if (changeTo != 'dynamic'){
		
		$("#gephi").show();
		$("#gephi").attr("href", 'http://linkedjazz.org/api/relationships/all/gexf');

	}else{
		$("#gephi").hide();
	}

 
	visMode = changeTo;

	$("#network").fadeOut(function(){
		
		$("#network").css("visibility","hidden");
		
		//if the popup has been shown make sure its hidden before the next view
		if(currentNode!=null){hidePopup();}


		
		showSpinner("Rendering<br>Network");		
		initalizeNetwork();		


		//we need to rest the zoom/pan
   		zoom.translate([0,0]).scale(1);
		vis.attr("transform", "translate(" + [0,0] + ")"  + " scale(" + 1 + ")");  		
		
		zoomWidgetObjDoZoom = false;	
		zoomWidgetObj.setValue(0,0.255555555); 		
		
		filter();

		rendering = false;
		
		
		
		
	});
	
	
		
	
	
}


//build the intial list used for dynamic mode
function buildDynamicList(){
	 

	var listNodes = baseNodes;
	listNodes.sort(function(a,b) {
		 var nameA=a.labelLast.toLowerCase(), nameB=b.labelLast.toLowerCase()
		 if (nameA < nameB) //sort string ascending
		  return -1 
		 if (nameA > nameB)
		  return 1
		 return 0 //default return value (no sorting)
	});

	var domFragment = $("<div>"); 
	
	for (x in listNodes){
	
		var id_css = listNodes[x].id;		
		var id_img =  listNodes[x].id ;
	 
		var descText = '';	
		  

		if (descObject[listNodes[x].id]){
			if (descObject[listNodes[x].id]['http://dbpedia.org/ontology/abstract']){
				var desc = descObject[listNodes[x].id]['http://dbpedia.org/ontology/abstract'][0].value;
				var r = /\\u([\d\w]{4})/gi;
				desc = desc.replace(r, function (match, grp) {
					return String.fromCharCode(parseInt(grp, 16)); } );
				desc = unescape(desc); 
				descText = decodeURIComponent(desc);
				descText = descText.replace(/&ndash;/gi,'-');
				descText = descText.replace(/&amp;/gi,'&');	

				var link = listNodes[x].id.replace('dbpedia','wikipedia').replace('resource','wiki');

				descText = descText.substring(0,250) + '...' + '<br>' + '<a class="popup-link" target="_blank" href="' + link + '">From Wikipedia</a><br><br>';	
				

			}else{
				descText = "";
			}
		}

 
		
		domFragment.append
		(
			$("<div>")
				.attr("id","dynamic_" + id_css)
				.addClass("dynamicListItem")
				.data("label",listNodes[x].labelLast)
				.data("id",listNodes[x].id)
				.click(function(){ if (dynamicPeople.indexOf($(this).data("id"))==-1){$("#dynamicClear").fadeIn(5000); $("#dynamicHelp").css("display","none"); usePerson = $(this).data("id"); dynamicPeople.push(usePerson); filter();}})
				.append
				(
					$("<img>")
						.attr("src",function()
						{
							 
 							if (fileNames.indexOf(id_img+'.png')!=-1){
								return "/image/round/" + id_img+'.png';
							}else{
								return "";	
							}
						})
						.css("visibility",function()
						{
							if (fileNames.indexOf(id_img+'.png')!=-1){
								return "visible"	
							}else{
								return "hidden"								
							}
						})
				
				)
				.append
				(
					$("<div>")
						.text(listNodes[x].labelLast)
						.attr("title", descText)					
					
				)				
		
		)
	}

	$("#dynamicListHolder").html(domFragment);

	window.orginalDynamicListFragment = domFragment;
	
	
}



function dynamicFilterList(){
	

	
	var searchTerm = $("#dynamicSearchInput").val().toLowerCase();

	$(".dynamicListItem").each(function(){
		
		if ($(this).data("label").toLowerCase().indexOf(searchTerm)==-1){
			$(this).css("display","none");
		}else{
			$(this).css("display","block");
		}
		
	});

	
		
}


//zoom/pan function called by mouse event
function redraw(useScale) {

	//store the last event data
	trans=d3.event.translate;
	scale=d3.event.scale;  


	//transform the vis
   vis.attr("transform",
      "translate(" + trans + ")"
      + " scale(" + scale + ")");   
	
	//we need to update the zoom slider, set the boolean to false so the slider change does not trigger a zoom change in the vis (from the slider callback function)  
	zoomWidgetObjDoZoom = false;	
	zoomWidgetObj.setValue(0,(scale/4)); 
	 
}

 

function loadYouTube(useId){

	var filename = useId + '.meta';
	$.get('img/' + filename, function(data) {

		var objectCode = youTubeObject.replace(/\<id\>/ig,data);
		
		
		$("#video").empty();
		$("#video").append(
			$("<a>")
				.text("[x] Close")
				.attr("href","#")
				.attr("id", "youTubeClose")
				.attr("title","Close Video")
				.click(function(event){
					$("#video").empty();
					event.stopPropagation();
					event.preventDefault();
				})
		
		);
		$("#video").append(objectCode);
		

	});	
	//youTubeObject
	
	
}



function edgeStrokeWidth(d){

	
	if (visMode=="person" || visMode=="dynamic"){
		
	 	
		if (nodes.length < 10){
			return 2;	
		}

		if (nodes.length < 30){
			return 1;	
		}		
		if (nodes.length < 40){
			return 0.5;	
		}		
				
		return .3;		
	}	
	
	 
	
	
	
	return 0.3;	
	
}


function edgeColor(d){
	if(d.connections  == undefined)
	return "#BCBDDC"
	 
	 return "#BCBDDC"
	if (visMode=='dynamic'){return "#666";}
	
	if (typeof d.connections == 'undefined'){  
		d = d.source;
	}
	
 	
	if (d.connections <= edgesAvg){		
		return "#bcbddc";	
	}
	if ((d.connections-edgesAvg)/edgesInterval <= 1.5){				
		return "#9ecae1";	
	}	
	if ((d.connections-edgesAvg)/edgesInterval <= 2.5){				
		return "#74c476";	
	}	
	return "#fdae6b";	
	
}

function linkStrength(d){
	
	if (visMode=="free"){
		//return Math.sqrt(d.source.connections)/15;		
		//return 0;
		return (d.source.connections / largestConnection) / 500;
	}	
	
	if (visMode=="wave"){
		return Math.sqrt(d.source.connections)/9;		
	}
	if (visMode=="person"){
		return 0.2;		
	}	
	
	if (visMode=="dynamic"){
		return 0.01;		
	}		
	
	if (visMode=="clique"){
		//return Math.sqrt(d.source.connections)/8;		
		
		//we want to find the combined simlarity between the two people
		var p1 = d.source.id;
		var p2 = d.target.id;		
		
		var strength = 0;
		 
		
		if (simlarityIndex[p1].hasOwnProperty(p2)){strength=simlarityIndex[p1][p2];}
		if (simlarityIndex[p2].hasOwnProperty(p1)){strength=strength+simlarityIndex[p2][p1];}		
		
		
		return (strength / (largestSimilarity*2));
		
	}	
	
}
function showSpinner(text){
	
	$("#spinner").css("left",($("#network").width()/2 ) - 65 + "px");
	$("#spinner").css("top", ($("#network").height()/2 ) - 65 + "px");
	$("#spinner").css("display","block");
	$("#spinner span").html(text);
		
	
}

function hideSpinner(){	
	$("#spinner").css("display","none");	
}

function windowResize(){
	 
	visWidth = $(window).width();
	visHeight = $(window).height();
	
 	
	$("#network").css('width', visWidth + 'px');
	$("#network").css('height',visHeight + 'px');
	$("#dynamicListHolder").css('height',visHeight - 110 + 'px');
	
	
	

	
	
}

