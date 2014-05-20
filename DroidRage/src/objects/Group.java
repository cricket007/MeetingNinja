package objects;

import java.util.ArrayList;

import objects.parcelable.ParcelDataFactory;
import objects.parcelable.UserParcel;

import android.os.Bundle;
import android.os.Parcel;
import android.os.Parcelable;

import com.meetingninja.csse.database.Keys;

public class Group implements Parcelable, Comparable<Group> {

	private String groupID;
	private String groupTitle;
	private ArrayList<User> members = new ArrayList<User>();

	public Group() {
		// Required empty constructor
	}

	public Group(Parcel in) {
		readFromParcel(in);
	}

	public Group(String groupID, String title) {
		setID(groupID);
		setTitle(title);
	}

	public String getGroupID() {
		return groupID;
	}

	public void setID(String id) {
		int testInt = Integer.valueOf(id);
		setID(testInt);
	}

	public void setID(int id) {
		this.groupID = Integer.toString(id);
	}

	public String getTitle() {
		return groupTitle;
	}

	public void setTitle(String groupTitle) {
		this.groupTitle = groupTitle;
	}

	public ArrayList<User> getMembers() {
		return members;
	}

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
		dest.writeString(getTitle());
//		dest.writeList(getMembers());
		ArrayList<UserParcel> userList = new ArrayList<UserParcel>();
		for (User user:getMembers()){
			userList.add(new UserParcel(user));
		}
		dest.writeList(userList);
	}

	@SuppressWarnings("unchecked")
	public void readFromParcel(Parcel in) {
		this.groupID = in.readString();
		this.groupTitle = in.readString();
		ArrayList<User> userParcelList = in.readArrayList(User.class.getClassLoader());
		for (int i=0;i<userParcelList.size();i++){
			Bundle extras = new Bundle();
			extras.putParcelable(Keys.User.PARCEL, (Parcelable) userParcelList.get(i));
			ParcelDataFactory dataFac = new ParcelDataFactory(extras);
			members.add(dataFac.getUser());
		}
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

	public String getID() {
		return groupID;
	}

	public void addMembers(ArrayList<User> members) {
		this.members.addAll(members);
	}

	@Override
	public int compareTo(Group another) {
		return this.getTitle().compareToIgnoreCase(another.getTitle());
	}
}
