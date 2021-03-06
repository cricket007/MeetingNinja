/*******************************************************************************
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 ******************************************************************************/
package com.meetingninja.csse.agenda;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import objects.Task;
import objects.Topic;
import pl.polidea.treeview.AbstractTreeViewAdapter;
import pl.polidea.treeview.TreeBuilder;
import pl.polidea.treeview.TreeNodeInfo;
import pl.polidea.treeview.TreeStateManager;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.support.v4.app.FragmentActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.doomonafireball.betterpickers.hmspicker.HmsPickerBuilder;
import com.doomonafireball.betterpickers.hmspicker.HmsPickerDialogFragment.HmsPickerDialogHandler;
import com.meetingninja.csse.R;
import com.meetingninja.csse.database.Keys;
import com.meetingninja.csse.tasks.EditTaskActivity;

public class AgendaItemAdapter extends AbstractTreeViewAdapter<Topic> {
	private final String TAG = AgendaItemAdapter.class.getSimpleName();

	private Context mContext;
	private TreeBuilder<Topic> builder;
	private TreeStateManager<Topic> manager;

	private static int _topics = 0;
	private final HashMap<Topic, Boolean> comparison;
	private final HashMap<EditText, TextWatcher> textHandlers;

	private boolean checked;

	private int counter;

	// private void changeSelected(final boolean isChecked, final Long id) {
	// if (isChecked) {
	// selected.add(id);
	// } else {
	// selected.remove(id);
	// }
	// }

	public AgendaItemAdapter(final Context context,
			final TreeStateManager<Topic> treeStateManager,
			TreeBuilder<Topic> treeBuilder, final int numberOfLevels) {
		super((Activity) context, treeStateManager, numberOfLevels);
		this.mContext = context;
		this.builder = treeBuilder;
		this.manager = treeStateManager;
		_topics = manager.getVisibleCount();
		comparison = new HashMap<Topic, Boolean>();
		textHandlers = new HashMap<EditText, TextWatcher>();
		checked = false;
		counter = 0;
	}

	private Map<String, String> getDescription(final Topic topic) {
		HashMap<String, String> values = new HashMap<String, String>();
		values.put("title", topic.getTitle());
		values.put("levels",
				Arrays.asList(getManager().getHierarchyDescription(topic))
						.toString());

		int totalMins = Integer.valueOf(topic.getTime()); // in minutes
		int hrs = totalMins / 60; // get hours
		int mins = totalMins % 60;
		if (totalMins >= 60) {
			values.put("time", String.format(" (%dh %02dm)", hrs, mins));
		} else if (totalMins >= 0) {
			values.put("time", String.format(" (%02dm)", hrs, mins));
		}

		return values;
	}

	@Override
	public View getNewChildView(final TreeNodeInfo<Topic> treeNodeInfo) {
		LayoutInflater inflater = getActivity().getLayoutInflater();
		final LinearLayout viewLayout = (LinearLayout) inflater.inflate(
				R.layout.list_item_agenda, null);
		View updated = updateView(viewLayout, treeNodeInfo);
		return updated;
	}

	public void addhash(Topic s) {
		comparison.put(s, true);
		checked = true;
		counter = 0;
	}

	@Override
	public LinearLayout updateView(final View view,
			final TreeNodeInfo<Topic> treeNodeInfo) {

		final LinearLayout rowView = (LinearLayout) view;

		final Topic rowTopic = treeNodeInfo.getId();

		// System.out.println("Echo: Checked" + rowTopic + " " + counter + " "
		// + Comparison.size() + " " + checked);

		final EditText mTitle = (EditText) rowView
				.findViewById(R.id.agenda_edit_topic);

		final TextView mTime = (TextView) rowView
				.findViewById(R.id.agenda_topic_time);
		if (textHandlers.containsKey(mTitle)) {
			mTitle.removeTextChangedListener(textHandlers.get(mTitle));
		}
		mTitle.setText(rowTopic.getTitle());

		// System.out.println("Echo: Here" + rowTopic.getTitle() + " " +
		// rowView);

		TextWatcher c = new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
				String text = s.toString();

				// rowTopic.setTitle(text);
				mTitle.setTag(text);
				rowTopic.setTitle(text);

				Log.d(TAG, "Text changed" + treeNodeInfo.getLevel() + " "
						+ treeNodeInfo.getId());
				manager.getChildren(treeNodeInfo.getId());

			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {

			}
		};

		mTitle.addTextChangedListener(c);
		textHandlers.put(mTitle, c);

		final Button mAddTopicBtn = (Button) rowView
				.findViewById(R.id.agenda_subtopicAddBtn);
		final Button mTimeBtn = (Button) rowView
				.findViewById(R.id.agenda_topicTimeBtn);
		System.out.println();

		// Add SubTopic Button
		// mAddTopicBtn.setTag(rowTopic);
		mAddTopicBtn.setOnClickListener(new SubTopicListener(rowTopic));

		// Set Time Button
		mTimeBtn.setTag(rowTopic);
		mTimeBtn.setOnClickListener(new OnTimeBtnClick(rowTopic, mTime));

		Map<String, String> info = getDescription(rowTopic);

		String time = info.containsKey("time") ? info.get("time") : "";
		time = "(" + rowTopic.getTime() + "m)";
		mTime.setText(time);

		// If a topic has subTopics, then its time is determined by the sum of
		// the subTopics
		if (getManager().getChildren(rowTopic).size() != 0) {
			// mTimeBtn.setVisibility(View.GONE);
			mTime.setVisibility(View.GONE);
			mTimeBtn.setVisibility(View.GONE);
		} else {
			mTime.setVisibility(View.VISIBLE);
			mTimeBtn.setVisibility(View.VISIBLE);
			// timeBtn.setChecked(selected.contains(treeNodeInfo.getId()));
		}
		getManager().notifyDataSetChanged();
		return rowView;
	}

	@Override
	public long getItemId(final int position) {

		return position;
	}

	@Override
	public int getViewTypeCount() {
		return 1;
	}

	private class OnTimeBtnClick implements OnClickListener {
		private final Topic topic;
		private final TextView changeText;

		public OnTimeBtnClick(Topic topic, TextView changeText) {
			this.topic = topic;
			this.changeText = changeText;
		}

		@Override
		public void onClick(final View v) {

			final CharSequence[] items = { "Set Time", "Create Task from Item",
					"Delete Topic" };

			AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
			builder.setTitle("Select an Option");
			builder.setItems(items, new DialogInterface.OnClickListener() {
				public void onClick(DialogInterface dialog, int item) {

					switch (item) {
					case 0:
						HmsPickerBuilder hms = new HmsPickerBuilder()
								.setFragmentManager(
										((FragmentActivity) getActivity())
												.getSupportFragmentManager())
								.setStyleResId(
										R.style.BetterPickersDialogFragment);
						hms.addHmsPickerDialogHandler(new HmsPickerDialogHandler() {

							@Override
							public void onDialogHmsSet(int reference,
									int hours, int minutes, int seconds) {
								topic.setTime("" + (minutes + hours * 60));
								changeText.setText(topic.getTime());

							}

						});
						hms.show();
						Topic t = (Topic) v.getTag();
						Map<String, String> info = getDescription(t);
						Log.d(TAG, info.get("title"));
						getManager().notifyDataSetChanged();
						break;
					case 1:

						Intent i = new Intent(getActivity(),
								EditTaskActivity.class);
						Task q = new Task();
						q.setTitle(topic.getTitle());
						i.putExtra(Keys.Task.PARCEL, q);
						((Activity) mContext).startActivityForResult(i, 7);

						break;
					case 2:

						break;
					default:
						break;
					}
				}
			});
			AlertDialog alert = builder.create();
			alert.show();

		}
	}

	private class SubTopicListener implements OnClickListener {
		private final Topic parent;

		public SubTopicListener(Topic parent) {
			this.parent = parent;
		}

		@Override
		public void onClick(View v) {
			// final Topic t = (Topic) v.getTag();
			Topic subT = new Topic(); // TODO : Make new subtopic
			subT.setTitle("");
			subT.setTime("0");
			parent.addTopic(subT);

			// System.out.println("Echo: Created" + subT + " " + parent);
			// List<Topic> childList = getManager().getChildren(parent);
			// System.out.println(childList.size());
			// if(childList.size()!=0){
			//
			// Topic nextChild = childList.get(childList.size()-1);
			// getManager().addAfterChild(parent, subT, nextChild);
			// }else{
			// getManager().addAfterChild(parent, subT, null);
			// }
			((AgendaActivity) mContext).reconstructTree();

			getManager().notifyDataSetChanged();
		}

	}
}
