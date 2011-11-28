function initTree(people) {
  //Create a new ST instance
  var st = new $jit.ST({
    //make it a multitree
    multitree: true,
    //set orientation of the tree
    orientation: 'top',
    //id of viz container element
    injectInto: 'infovis',
    //set distance between node and its children
    levelDistance: 30,
    //set the number of levels to show
    levelsToShow: 3,
    //enable panning
    Navigation: {
      enable:true,
      panning:true
    },
    //set node and edge styles
    //set overridable=true for styling individual
    //nodes or edges
    Node: {
      height: 20,
      width: 80,
      type: 'rectangle',
      color: '#aaa',
      autoHeight: false,
      autoWidth: true,
      overridable: true
    },

    Edge: {
      type: 'bezier',
      overridable: true
    },

    //This method is called on DOM label creation.
    //Use this method to add event handlers and styles to
    //your node.
    onCreateLabel: function(label, node) {
      label.id = node.id;
      label.innerHTML = node.name;
      label.onclick = function() {
        if (node.selected) {
          document.location.href = '/people/'+node.id;
        } else {
          document.location.href = '/people/'+node.id+'/tree';
        }
      };
      //set label styles
      var style = label.style;
      style.width = '';
      style.height = '';
      style.cursor = 'pointer';
      style.color = '#333';
      style.fontSize = '0.8em';
      style.textAlign= 'center';
      style.padding = '16px';
    },

    //This method is called right before plotting
    //a node. It's useful for changing an individual node
    //style properties before plotting it.
    //The data properties prefixed with a dollar
    //sign will override the global node style properties.
    onBeforePlotNode: function(node) {
      //add some color to the nodes in the path between the
      //root node and the selected node.
      if (node.selected) {
        node.data.$color = "#ff7";
      }
      else {
        delete node.data.$color;
        //if the node belongs to the last plotted level
        if(!node.anySubnode("exist")) {
          //count children number
          var count = 0;
          node.eachSubnode(function(n) { count++; });
          //assign a node color based on
          //how many children it has
          node.data.$color = ['#aaa', '#baa', '#caa', '#daa', '#eaa', '#faa'][count];
        }
      }
    },

    //This method is called right before plotting
    //an edge. It's useful for changing an individual edge
    //style properties before plotting it.
    //Edge data proprties prefixed with a dollar sign will
    //override the Edge global style properties.
    onBeforePlotLine: function(adj) {
      if (adj.nodeFrom.selected && adj.nodeTo.selected) {
        adj.data.$color = "#eed";
        adj.data.$lineWidth = 3;
      }
      else {
        delete adj.data.$color;
        delete adj.data.$lineWidth;
      }
    }
  });
  //load json data
  st.loadJSON(people);
  //compute node positions and layout
  st.compute();
  st.select(st.root);

  $( "#infovis" ).resizable();
}


