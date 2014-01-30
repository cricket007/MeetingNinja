var TaskArray;
var deleteID;

function hideViewModal(){
	$('#viewTaskModal').modal('hide');
}

function showDeleteModal(ID){
	deleteID = ID;
	$('#deleteTaskModal').modal('show');
}

function hideDeleteModal(){
	// TODO: Put this back in when it works and change it to the delete
	// $.ajax({
	//         type: 'GET',
	//         url: 'http://csse371-04.csse.rose-hulman.edu/Tasks/' + deletelID,
	//   success:function(data){
	//     if(data.taskID != null){
	//       TaskArray = JSON.parse(data);
	//     }
	//   }
	// });
	alert("The task matching id " + deleteID + " was deleted");

	$('#deleteTaskModal').modal('hide');
	// TODO: Put back in
	//location.reload(true);
}

function showEditModal(){
	$('#editTaskModal').modal('hide');
	$('#editTaskModal').on('hidden.bs.modal', function() {
		$(this).removeData('bs.modal');
	});
	// TODO: Put this back in when it works
	// $.ajax({
	//         type: 'GET',
	//         url: 'http://csse371-04.csse.rose-hulman.edu/Tasks/' + ID,
	//   success:function(data){
	//     if(data.taskID != null){
	//       TaskArray = JSON.parse(data);
	//     }
	//   }
	// });

	document.getElementById("titleE").value = TaskArray["title"];
	document.getElementById("isCompletedE").checked = TaskArray["isCompleted"];
	document.getElementById("descriptionE").value = TaskArray["description"];
	document.getElementById("deadlineE").value = TaskArray["deadline"];
	document.getElementById("completionCriteriaE").value = TaskArray["completionCriteria"];
	document.getElementById("assignedToE").value = TaskArray["assignedTo"];

	$('#editTaskModal').modal('show');
	$('#viewTaskModal').modal('hide');
}

function showViewModalNoID(){
	$('#viewTaskModal').modal('hide');
	$('#viewTaskModal').on('hidden.bs.modal', function() {
		$(this).removeData('bs.modal');
	});
}

function showViewModal(ID){
	$('#viewTaskModal').modal('hide');
	$('#viewTaskModal').on('hidden.bs.modal', function() {
		$(this).removeData('bs.modal');
	});
	// TODO: Put this back in when it works
	// $.ajax({
	//         type: 'GET',
	//         url: 'http://csse371-04.csse.rose-hulman.edu/Tasks/' + ID,
	//   success:function(data){
	//     if(data.taskID != null){
	//       TaskArray = JSON.parse(data);
	//     }
	//   }
	// });

	if (ID == 1){
		TaskArray = JSON.parse ('{"taskID":"1","title":"Delete a Task","isCompleted":"false","description":"Allows the user to delete a task","deadline":"19-Dec-13","dateCreated":"16-Dec-13","dateAssigned":"16-Dec-13","completionCriteria":"Must remove the specified task from the database and be verified by client","assignedTo":"Lindsey","assignedFrom":"Lindsey","createdBy":"Lindsey"}');
	}else if (ID == 2){
		TaskArray = JSON.parse('{"taskID":"2","title":"Create a Meeting","isCompleted":"false","description":"Allows the user to create a meeting","deadline":"19-Dec-13","dateCreated":"16-Dec-13","dateAssigned":"16-Dec-13","completionCriteria":"Must add the meeting information to the database and be verified by client","assignedTo":"Jonathan","assignedFrom":"Lindsey","createdBy":"Lindsey"}');
	}else if (ID == 3){
		TaskArray = JSON.parse('{"taskID":"3","title":"Create a Task","isCompleted":"false","description":"Allows the user to create a task","deadline":"19-Dec-13","dateCreated":"16-Dec-13","dateAssigned":"16-Dec-13","completionCriteria":"Must add the specified task to the database and be verified by client","assignedTo":"Lindsey","assignedFrom":"Lindsey","createdBy":"Lindsey"}');
	}else if (ID == 4){
		TaskArray = JSON.parse('{"taskID":"4","title":"View a Task","isCompleted":"false","description":"Allows the user to view a task","deadline":"19-Dec-13","dateCreated":"16-Dec-13","dateAssigned":"16-Dec-13","completionCriteria":"Must view the specified task and be verified by client","assignedTo":"Lindsey","assignedFrom":"Lindsey","createdBy":"Lindsey"}');
	}

	document.getElementById("titleV").innerHTML = TaskArray["title"];
	document.getElementById("isCompletedV").innerHTML = TaskArray["isCompleted"];
	document.getElementById("descriptionV").innerHTML = TaskArray["description"];
	document.getElementById("deadlineV").innerHTML = TaskArray["deadline"];
	document.getElementById("dateCreatedV").innerHTML = TaskArray["dateCreated"];
	document.getElementById("dateAssignedV").innerHTML = TaskArray["dateAssigned"];
	document.getElementById("completionCriteriaV").innerHTML = TaskArray["completionCriteria"];
	document.getElementById("assignedToV").innerHTML = TaskArray["assignedTo"];
	document.getElementById("assignedFromV").innerHTML = TaskArray["assignedFrom"];
	document.getElementById("createdByV").innerHTML = TaskArray["createdBy"];

	$('#viewTaskModal').modal('show');
	$('#editTaskModal').modal('hide');
}

function validateForm(){
	var title = document.forms["input"]["title"].value;
	var description = document.forms["input"]["description"].value;
	var deadline = document.forms["input"]["deadline"].value;
	var completionCriteria = document.forms["input"]["completionCriteria"].value;
	var assignedTo = document.forms["input"]["assignedTo"].value;

	if(title.length == 0 || description.length == 0 || !checkDeadlineFormat(deadline) || completionCriteria.length == 0 || assignedTo.length == 0) {
		var string = "The following fields need filled or modified: \n\n";
		if(title.length == 0) string = string + "Title\n";
		if(description.length == 0) string = string + "Description\n";
		if(!checkDeadlineFormat(deadline)) string = string + "Deadline (format = 'MM/DD/YYYY_HH:MM', where the underscore is a space)\n";
		if(completionCriteria.length == 0) string = string + "Completion Criteria\n";
		if(assignedTo.length == 0) string = string + "Assigned To\n";
		alert(string);
		return false;
	}else{
		alert("The following fields were added to the db: " + title + " " + description + " " + deadline + " " + completionCriteria + " " + assignedTo)
		return true;
	}
}

function checkDeadlineFormat(deadline){
	if(deadline.length == 0) return false;
	else {
		var array = deadline.split('');
		var date = new Date()
		var month = parseInt(deadline.substring(0,2));
		var day = parseInt(deadline.substring(3,5));
		var year = parseInt(deadline.substring(6, 10));
		var hours = parseInt(deadline.substring(11, 13));
		var minutes = parseInt(deadline.substring(14, 16));
		if(!(!isNaN(array[0]) && !isNaN(array[1]) && !isNaN(array[3]) && !isNaN(array[4]) && !isNaN(array[6]) && !isNaN(array[7]) && !isNaN(array[8]) && !isNaN(array[9]) && !isNaN(array[11]) && !isNaN(array[12]) && !isNaN(array[14]) && !isNaN(array[15]))) return false;
		else if(array[2] != '/' || array[5] != '/' || array[10] != ' ' || array[13] != ':') return false;
		else if(day > 31 || day == 0 || month > 12 || month == 0 || year < date.getFullYear() || hours > 23 || minutes > 59) return false;
		else return true;
	}
}