package objects;

import java.util.ArrayList;

import android.os.Parcel;
import android.os.Parcelable;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

@JsonInclude(JsonInclude.Include.NON_NULL)
// Generated by http://www.jsonschema2pojo.org/
@JsonPropertyOrder({ "groupID", "groupTitle", "members" })
public class Group extends Event implements Parcelable {

	@JsonProperty("groupID")
	private String groupID;
	@JsonProperty("groupTitle")
	private String groupTitle;
	@JsonProperty("members")
	private ArrayList<User> members = new ArrayList<User>();

	public Group() {
		// Required empty constructor
	}

	public Group(Parcel in) {
		readFromParcel(in);
	}

	public Group(String groupID, String title) {
		setID(groupID);
		setGroupTitle(title);
	}

	@JsonProperty("groupID")
	public String getGroupID() {
		return groupID;
	}

	@JsonProperty("groupID")
	public void setID(String id) {
		int testInt = Integer.valueOf(id);
		setID(testInt);
	}

	@JsonProperty("groupID")
	public void setID(int id) {
		this.groupID = Integer.toString(id);
	}

	@JsonProperty("groupTitle")
	public String getGroupTitle() {
		return groupTitle;
	}

	@JsonProperty("groupTitle")
	public void setGroupTitle(String groupTitle) {
		this.groupTitle = groupTitle;
	}

	@JsonProperty("members")
	public ArrayList<User> getMembers() {
		return members;
	}

	@JsonProperty("members")
	public void setMembers(ArrayList<User> members) {
		this.members = members;
	}

	public void addMember(User user) {
		this.members.add(user);
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(getGroupID());
		dest.writeString(getGroupTitle());
		dest.writeList(getMembers());
	}

	public void readFromParcel(Parcel in) {
		this.groupID = in.readString();
		this.groupTitle = in.readString();
		this.members = in.readArrayList(User.class.getClassLoader());
	}

	public static final Parcelable.Creator<Group> CREATOR = new Parcelable.Creator<Group>() {

		@Override
		public Group createFromParcel(Parcel in) {
			return new Group(in);
		}

		@Override
		public Group[] newArray(int size) {
			return new Group[size];
		}

	};

	@Override
	public String getID() {
		return groupID;
	}

	public void addMembers(ArrayList<User> members) {
		this.members.addAll(members);

	}

}
