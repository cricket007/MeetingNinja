// Top Abstract Modal
function NinjaModal(documentID, objectID){
	var self = this;
	return{
		showModal: function(){
			$('#' + documentID).modal('show');
		},

		addElement: function(type, value, id, name, itemClass, documentPosition){
			var element = document.createElement("input");

			if(type != ""){
				element.setAttribute("type", type);

				if(value != ""){
					element.setAttribute("value", value);
				}
				if(id != ""){
					element.setAttribute("id", id);
				}
				if(name != ""){
					element.setAttribute("name", name);
				}
				if(itemClass != ""){
					element.setAttribute("class", itemClass);
				}
				var doc = document.getElementById(documentPosition);
				doc.appendChild(element);
			}
		},

		addText: function(value, id, itemClass, documentPosition){
			var span = document.createElement("span");
			var text = document.createTextNode(value);
			if(itemClass != ""){
				span.setAttribute("class", itemClass);
			}
			if(id != ""){
					span.setAttribute("id", id);
			}
			span.appendChild(text);
			var doc = document.getElementById(documentPosition);
			doc.appendChild(span);

			var el = document.createElement("br");
			doc.appendChild(el);
		},

		addBreak: function(documentPosition){
			var el = document.createElement("br");
			var doc = document.getElementById(documentPosition);
			doc.appendChild(el);
		},

		close: function(){
			var div = document.getElementById('header');
			while(div.firstChild){
    			div.removeChild(div.firstChild);
			}
			var div = document.getElementById('body');
			while(div.firstChild){
    			div.removeChild(div.firstChild);
			}
			var div = document.getElementById('footer');
			while(div.firstChild){
    			div.removeChild(div.firstChild);
			}
			$('#' + documentID).modal('hide');
		},

		/* From this point on, the methods are methods that do not pertain 
			to the modal but are used in every modal for element population
		*/ 

		returnSelectValuesAsJSON: function(JSONtype, JSONDisplayColumn, JSONValueColumn, selectID){
			var select = document.getElementById(selectID);
			var newJSONString = "{" + "\"" + JSONtype + "\"" + ":[";

			for (var j in select.options){
				if(select.options[j].selected){
					newJSONString = newJSONString + "{" + "\"" + JSONValueColumn + "\":\"" + select.options[j].value + "\",\"" + JSONDisplayColumn + "\":\"" + select.options[j].textContent + "\"},";
				}
			}

			newJSONString = newJSONString.substring(0, newJSONString.length - 1);
			newJSONString = newJSONString + "]}";
			var newJSON = JSON.parse(newJSONString);
			return newJSON[JSONtype];
		},

		convertFormToJSON: function(form){
			var array = jQuery(form).serializeArray();
			var json = {};

			jQuery.each(array, function() {
				json[this.name] = this.value || '';
			});

			return json;
		},

		hasSelectedValue: function(selectID){
			var select = selectID;

			for (var j in select.options){
				if(select.options[j].selected){
					return true
				}
			}
			return false
		},

		/* DOCUMENTATION FOR POPULATESELECT
			Populates the select tag specified by 'selectID'
			with text from JSONArray elements with JSONDisplayColumn data
			and value from JSONArray elements with JSONValueColumn data.
			Sets the values in JSONSelectValues to 'selected' in the newly
			populated select tag.
		*/
		
		populateSelect: function(JSONArray, JSONDisplayColumn, JSONValueColumn, JSONSelectValues, selectID){
			// get select tag
			var select = selectID;

			// empty select tag
			if(select.options.length != 0){
				for(var i = select.options - 1; i > -1; i--){
					select.remove(i);
				}
			}

			// populate select tag
			for (var k in JSONArray){
				if(JSONArray[k][JSONDisplayColumn] != null){
					var el = document.createElement("option");
					el.textContent = JSONArray[k][JSONDisplayColumn];
					el.value = JSONArray[k][JSONValueColumn];
					select.appendChild(el);
				}
			}

			// set currently selected items to be selected
			for (var i in JSONSelectValues){
				for (var j in select.options){
					if(JSONSelectValues[i][JSONValueColumn] == select.options[j].value){
						select.options[j].selected = true;
						break;
					}
				}
			}

			return select;
		}
	}
}

// Delete Abstract Modal
function DeleteModal(documentID, deleteID){
	var deleteModal = NinjaModal(documentID, deleteID);

	var parentShow = deleteModal.showModal;
	var parentAddText = deleteModal.addText;
	var parentClose = deleteModal.close;

	deleteModal.showModal = function(object){
		deleteModal.createHeader(object);
		deleteModal.createBody(object);
		deleteModal.createFooter(object);
		parentShow.call(this);
	}

	deleteModal.createHeader = function(object){
		var header = document.createElement("h1");
		header.setAttribute("class", "modal-title");
		var text = document.createTextNode("Delete " + object);
		header.appendChild(text);
		var doc = document.getElementById("header");
		doc.appendChild(header);
	}

	deleteModal.createBody = function(object){
		parentAddText.call(this,"Are you sure you want to delete this " + object + "?","", "viewLabel", "body");
	}

	deleteModal.createFooter = function(object){
		// Close button
		var elementClose = document.createElement("button");
		elementClose.setAttribute("class", "btn btn-primary");
		elementClose.innerHTML = "Close";
		elementClose.onclick = parentClose;

		// ActionButton
		var elementDelete = document.createElement("input");
		elementDelete.setAttribute("type", "button");
		elementDelete.onclick = deleteModal.executeAction;
		elementDelete.setAttribute("class", "btn btn-primary");
		elementDelete.value = "Delete";

		var doc = document.getElementById("footer");
		doc.appendChild(elementClose);
		doc.appendChild(elementDelete);

	}

	deleteModal.executeAction = function(object){
		$.ajax({
		    type: 'DELETE',
		    url: 'http://csse371-04.csse.rose-hulman.edu/' + object + '/' + deleteID,
		    success:function(data){
			    if(JSON.parse(data)["valid"] == "true"){
			    	this.close;
			        window.location.reload(true);
			    }else{
			        alert('Delete Error');
			        this.close;
			    }
		    }
		});

	}

	return deleteModal
}

// NewGroup Modal
function NewGroupModal(documentID, blankID){
	var newModal = NinjaModal(documentID, blankID);

	var parentShow = newModal.showModal;
	var parentAddText = newModal.addText;
	var parentAddBreak = newModal.addBreak;
	var parentAddElement = newModal.addElement;
	var parentPopulateSelect = newModal.populateSelect;
	var parentConvertToJSON = newModal.convertFormToJSON;
	var parentHasSelected = newModal.hasSelectedValue;
	var parentClose = newModal.close;

	newModal.showModal = function(users){

		newModal.createHeader();
		newModal.createBody(users);
		newModal.createFooter();
		parentShow.call(this);
	}

	newModal.createHeader = function(){
		var header = document.createElement("h1");
		header.setAttribute("class", "modal-title");
		var text = document.createTextNode("Create Group");
		header.appendChild(text);
		var doc = document.getElementById("header");
		doc.appendChild(header);
	}

	newModal.createBody = function(users){
		alert(users);
		parentAddText.call(this, "* Indicate required fields.","","", "body");
		parentAddBreak.call(this,"body");
		parentAddText.call(this, "Group Title*","","", "body");
		parentAddElement.call(this, "text", "", "title", "title", "", "body");
		parentAddText.call(this, "Required", "titleR", "required", "body");
		parentAddBreak.call(this, "body");
		
		parentAddText.call(this, "Group Members*","","", "body");
		var doc = document.getElementById("body");
		var element = document.createElement("select");
		element.setAttribute("class","form-control");
		element.setAttribute("multiple","multiple");
		element.setAttribute("size","6");
		element.setAttribute("id", "members")

		element = parentPopulateSelect.call(this, users, "name", "userID", "", element);
		doc.appendChild(element);

		parentAddText.call(this, "Required", "membersR", "required", "body");
		parentAddBreak.call(this,"body");
	}

	newModal.createFooter = function(){
		// Close button
		var elementClose = document.createElement("button");
		elementClose.setAttribute("class", "btn btn-primary");
		elementClose.innerHTML = "Close";
		elementClose.onclick = parentClose;

		// ActionButton
		var elementSubmit = document.createElement("input");
		elementSubmit.setAttribute("type", "button");
		elementSubmit.onclick = newModal.executeAction;
		elementSubmit.setAttribute("class", "btn btn-primary");
		elementSubmit.value = "Submit";

		var doc = document.getElementById("footer");
		doc.appendChild(elementClose);
		doc.appendChild(elementSubmit);
	}

	newModal.executeAction = function(){
		var invalid = newModal.validate();
		if(!invalid){
			var form = new parentConvertToJSON(this, document.getElementById("body"))
			
			var uid = getCookie('userID');
		    var postTitle = form.title;
		    var members = getMembers('members');

		    var postMembers = [{"userID":uid}];

		    for (var i = members.length - 1; i >= 0; i--) {
		        postMembers.push({"userID":members[i]});
		    };

		    //set up the data for the call
		    var postData = JSON.stringify({
		        "groupTitle":postTitle,
		        "members":postMembers
		    });

			$.ajax({
				type: 'POST',
				url: 'http://csse371-04.csse.rose-hulman.edu/Group/',
				data: postData,
				success:function(data){
					parentClose.call(this);
					window.location.reload(true);
				}
			});
		}
	}

	newModal.validate = function(){
		var invalidFields = false;
  
		if(document.getElementById("title") != null && document.getElementById("titleR") != null){
			if(document.getElementById("title").value == ""){
				invalidFields = true;
				document.getElementById("titleR").style.display = "inline";
			}
			else{
				document.getElementById("titleR").style.display = "none";
			}
		}

		if(document.getElementById("members") != null && document.getElementById("membersR") != null){
			var result = parentHasSelected(this, document.getElementById("members"));
			if(!result){
				invalidFields = true;
				document.getElementById("membersR").style.display = "inline";
			}
			else{
				document.getElementById("membersR").style.display = "none";
			}
		}

		return invalidFields
	}

	newModal.getMembers = function(id){
		var newMembers = [];
		$( '#' + id + ' :selected' ).each( function( i, selected ) {
			newMembers[i] = $( selected ).val();
		});
		return newMembers;
	}

	return newModal
}

// EditGroup Modal
function EditGroupModal(documentID, groupID){
	var editModal = NinjaModal(documentID, groupID);

	var parentShow = editModal.showModal;
	var parentAddText = editModal.addText;
	var parentAddBreak = editModal.addBreak;
	var parentAddElement = editModal.addElement;
	var parentPopulateSelect = editModal.populateSelect;
	var parentConvertToJSON = editModal.convertFormToJSON;
	var parentHasSelected = editModal.hasSelectedValue;
	var parentClose = editModal.close;

	editModal.showModal = function(users){

		editModal.createHeader();
		editModal.createBody(users);
		editModal.createFooter(users);
		parentShow.call(this);
	}

	editModal.createHeader = function(){
		var header = document.createElement("h1");
		header.setAttribute("class", "modal-title");
		var text = document.createTextNode("Edit Group");
		header.appendChild(text);
		var doc = document.getElementById("header");
		doc.appendChild(header);
	}

	editModal.createBody = function(users){
		alert(users);
		parentAddText.call(this, "* Indicate required fields.","","", "body");
		parentAddBreak.call(this,"body");
		parentAddText.call(this, "Group Title*","","", "body");
		parentAddElement.call(this, "text", "", "title", "title", "", "body");
		parentAddText.call(this, "Required", "titleR", "required", "body");
		parentAddBreak.call(this, "body");
		
		parentAddText.call(this, "Group Members*","","", "body");
		var doc = document.getElementById("body");
		var element = document.createElement("select");
		element.setAttribute("class","form-control");
		element.setAttribute("multiple","multiple");
		element.setAttribute("size","6");
		element.setAttribute("id", "members")

		element = parentPopulateSelect.call(this, users, "name", "userID", "", element);
		doc.appendChild(element);

		parentAddText.call(this, "Required", "membersR", "required", "body");
		parentAddBreak.call(this,"body");

		var groupArray;

		$.ajax({
			type: 'GET',
			url: 'http://csse371-04.csse.rose-hulman.edu/Group/' + id,
			success:function(data){
				groupArray = JSON.parse(data);
			},
			async: false
		});

		for (i in groupArray['members']){
			mid = groupArray['members'][i]['userID'];
			$.ajax({
				type: 'GET',
				url: 'http://csse371-04.csse.rose-hulman.edu/User/' + mid,
				success:function(data){
					membInfo = JSON.parse(data);
					currentMembs.push({'mid':mid,'name':membInfo['name']});
				},
				async: false
			});
		}

		document.getElementById("title").value = groupArray["groupTitle"];

		populateSelect([], "name", "mid", currentMembs, document.getElementById("members"));
	}

	editModal.close = function(users){
		parentClose.call(this);
		var ModalFactory = abstractModalFactory();
		var modal = ModalFactory.createModal(ViewGroupModal, "GroupModal", groupID);

  		modal.showModal(users);
	}

	editModal.createFooter = function(users){
		// Close button
		var elementClose = document.createElement("button");
		elementClose.setAttribute("class", "btn btn-primary");
		elementClose.innerHTML = "Close";
		elementClose.onclick = editModal.close(users);

		// ActionButton
		var elementSubmit = document.createElement("input");
		elementSubmit.setAttribute("type", "button");
		elementSubmit.onclick = editModal.executeAction(users);
		elementSubmit.setAttribute("class", "btn btn-primary");
		elementSubmit.value = "Submit";

		var doc = document.getElementById("footer");
		doc.appendChild(elementClose);
		doc.appendChild(elementSubmit);
	}

	editModal.executeAction = function(users){
		var invalid = editModal.validate();
		if(!invalid){
			var form = new parentConvertToJSON(this, document.getElementById("body"))
			
			var postTitle = form.title;
			var members = getMembers('membersE');

			var postMembers = new Array();

			for (var i = members.length - 1; i >= 0; i--) {
				postMembers.push({"userID":members[i]});
			};

			//set up the data for the call
			var updateTitle = JSON.stringify({
				"groupID":groupID,
				"field":"groupTitle",
				"value":postTitle
			});

			var updateMembers = JSON.stringify({
				"groupID":groupID,
				"field":"members",
				"value":postMembers
			});

			$.ajax({
				type: 'PUT',
				url: 'http://csse371-04.csse.rose-hulman.edu/Group/',
				data: updateTitle,
				success:function(data){
				// do nothing
				},
				async: false
			})

			$.ajax({
			type: 'PUT',
				url: 'http://csse371-04.csse.rose-hulman.edu/Group/',
				data: updateMembers,
				success:function(data){
					parentClose.call(this);
					var ModalFactory = abstractModalFactory();
					var modal = ModalFactory.createModal(ViewGroupModal, "GroupModal", groupID);

			  		modal.showModal(users);
					window.location.reload(true);
				}
			});
		}
	}

	editModal.validate = function(){
		var invalidFields = false;
  
		if(document.getElementById("title") != null && document.getElementById("titleR") != null){
			if(document.getElementById("title").value == ""){
				invalidFields = true;
				document.getElementById("titleR").style.display = "inline";
			}
			else{
				document.getElementById("titleR").style.display = "none";
			}
		}

		if(document.getElementById("members") != null && document.getElementById("membersR") != null){
			var result = parentHasSelected(this, document.getElementById("members"));
			if(!result){
				invalidFields = true;
				document.getElementById("membersR").style.display = "inline";
			}
			else{
				document.getElementById("membersR").style.display = "none";
			}
		}

		return invalidFields
	}

	editModal.getMembers = function(id){
		var newMembers = [];
		$( '#' + id + ' :selected' ).each( function( i, selected ) {
			newMembers[i] = $( selected ).val();
		});
		return newMembers;
	}

	return editModal
}

// ViewGroup Modal
function ViewGroupModal(documentID, groupID){
	var viewModal = NinjaModal(documentID, groupID);

	var parentShow = viewModal.showModal;
	var parentAddText = viewModal.addText;
	var parentAddBreak = viewModal.addBreak;
	var parentAddElement = viewModal.addElement;
	var parentClose = viewModal.close;

	viewModal.showModal = function(users){
		viewModal.createHeader();
		viewModal.createBody(users);
		viewModal.createFooter(users);
		parentShow.call(this);
	}

	viewModal.createHeader = function(){
		var header = document.createElement("h1");
		header.setAttribute("class", "modal-title");
		var text = document.createTextNode("View Group");
		header.appendChild(text);
		var doc = document.getElementById("header");
		doc.appendChild(header);
	}

	viewModal.createBody = function(users){
		alert(users);
		parentAddText.call(this, "* Indicate required fields.","","", "body");
		parentAddBreak.call(this,"body");
		parentAddText.call(this, "Group Title*","","", "body");
		parentAddElement.call(this, "text", "", "title", "title", "", "body");
		parentAddText.call(this, "Required", "titleR", "required", "body");
		parentAddBreak.call(this, "body");

	}

	viewModal.createFooter = function(users){
		// Close button
		var elementClose = document.createElement("button");
		elementClose.setAttribute("class", "btn btn-primary");
		elementClose.innerHTML = "Close";
		elementClose.onclick = parentClose;

		// ActionButton
		var elementSubmit = document.createElement("input");
		elementSubmit.setAttribute("type", "button");
		elementSubmit.onclick = viewModal.executeAction(users);
		elementSubmit.setAttribute("class", "btn btn-primary");
		elementSubmit.value = "Submit";

		var doc = document.getElementById("footer");
		doc.appendChild(elementClose);
		doc.appendChild(elementSubmit);
	}

	viewModal.executeAction = function(users){
		parentClose.call(this);
		var ModalFactory = abstractModalFactory();
		var modal = ModalFactory.createModal(EditGroupModal, "GroupModal", groupID);

  		modal.showModal(users);
	}

	return viewModal
}