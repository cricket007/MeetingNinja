package objects;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;

import android.os.Parcel;
import android.os.Parcelable;

import com.fasterxml.jackson.core.JsonEncoding;
import com.fasterxml.jackson.core.JsonFactory;
import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.core.JsonGenerator;

public class Task extends Event implements Parcelable {
	private String taskID;
	private boolean isCompleted;
	private String dateCreated;
	private String dateAssigned;
	private String completionCriteria;
	private String assignedTo;
	private String assignedFrom;
	private String createdBy;
	private String type; // title, description, isCompleted, deadline,
							// compeltion criteria, assigned to

	public Task() {
		// Required empty constructor
	}

	public Task(String name) {
		this.title = name;
	}

	public Task(Parcel parcel) {
		readFromParcel(parcel);
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getType() {
		return this.type;
	}

	public boolean getIsCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(boolean isCompleted) {
		this.isCompleted = isCompleted;
	}

	public String getDateCreated() {
		return dateCreated;
	}

	public void setDateCreated(String dateCreated) {
		this.dateCreated = dateCreated;
	}

	public String getDateAssigned() {
		return dateAssigned;
	}

	public void setDateAssigned(String dateAssigned) {
		this.dateAssigned = dateAssigned;
	}

	public String getCompletionCriteria() {
		return completionCriteria;
	}

	public void setCompletionCriteria(String completionCriteria) {
		this.completionCriteria = completionCriteria;
	}

	public String getAssignedTo() {
		return assignedTo;
	}

	public void setAssignedTo(String assignedTo) {
		this.assignedTo = assignedTo;
	}

	public String getAssignedFrom() {
		return assignedFrom;
	}

	public void setAssignedFrom(String assignedFrom) {
		this.assignedFrom = assignedFrom;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	@Override
	public String getID() {
		return this.taskID;
	}

	@Override
	public void setID(int id) {
		this.taskID = Integer.toString(id);
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		// TODO Auto-generated method stub
		dest.writeString(getTitle());
		dest.writeString(Boolean.toString(getIsCompleted()));
		dest.writeString(getDescription());
		dest.writeString(getEndTime());
		dest.writeString(getDateCreated());
		dest.writeString(getDateAssigned());
		dest.writeString(getCompletionCriteria());
		dest.writeString(getAssignedTo());
		dest.writeString(getAssignedFrom());
		dest.writeString(getCreatedBy());
		dest.writeString(getID());
		dest.writeString(getType());
	}

	public void readFromParcel(Parcel in) {
		title = in.readString();
		isCompleted = Boolean.parseBoolean(in.readString());
		description = in.readString();
		endTime = in.readString();
		dateCreated = in.readString();
		dateAssigned = in.readString();
		completionCriteria = in.readString();
		assignedTo = in.readString();
		assignedFrom = in.readString();
		createdBy = in.readString();
		taskID = in.readString();
		type = in.readString();

	}

	public static final Parcelable.Creator<Task> CREATOR = new Parcelable.Creator<Task>() {
		@Override
		public Task createFromParcel(Parcel in) {
			return new Task(in);
		}

		@Override
		public Task[] newArray(int size) {
			return new Task[size];
		}
	};

	public static String toJSON(Task task) throws JsonGenerationException,
			IOException {
		ByteArrayOutputStream _json = new ByteArrayOutputStream();
		// this type of print stream allows us to get a string easily
		PrintStream ps = new PrintStream(_json);
		// Create a generator to build the JSON string
		JsonGenerator jgen = new JsonFactory().createGenerator(ps,
				JsonEncoding.UTF8);

		// Build JSON Object
		jgen.writeStartObject();
		jgen.writeStringField("taskID", task.getID());
		jgen.writeBooleanField("isCompleted", task.getIsCompleted());
		jgen.writeStringField("description", task.getDescription());
		jgen.writeStringField("deadline", task.getEndTime());
		jgen.writeStringField("dateCreated", task.getDateCreated());
		jgen.writeStringField("dateAssigned", task.getDateAssigned());
		jgen.writeStringField("completionCriteria",
				task.getCompletionCriteria());
		jgen.writeStringField("assignedTo", task.getAssignedTo());
		jgen.writeStringField("assignedFrom", task.getAssignedFrom());
		jgen.writeStringField("createdBy", task.getCreatedBy());
		jgen.close();

		String json = _json.toString("UTF8");
		ps.close();
		return json;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder();
		builder.append("*** Task Details ***\n");
		builder.append("getTaskID()\t");
		builder.append(getID() + "\n");
		builder.append("getTitle()\t");
		builder.append(getTitle() + "\n");
		builder.append("getDescription()\t");
		builder.append(getDescription() + "\n");
		builder.append("getDateCreated()\t");
		builder.append(getDateCreated() + "\n");
		builder.append("getDeadline()\t");
		builder.append(getEndTime() + "\n");
		builder.append("getIsCompleted()\t");
		builder.append(getIsCompleted() + "\n");
		builder.append("getAssignedTo()\t");
		builder.append(getAssignedTo() + "\n");
		builder.append("getCreatedBy()\t");
		builder.append(getCreatedBy() + "\n");
		builder.append("getAssingedFrom()\t");
		builder.append(getAssignedFrom() + "\n");
		builder.append("getType()\t");
		builder.append(getType() + "\n");
		return builder.toString();
	}
}