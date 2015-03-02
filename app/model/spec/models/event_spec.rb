require 'spec_helper'

describe Event do

  context "finding workshops" do
    let(:workshop) { create(:workshop) }

    context "that need their first notification" do
      it "should include a workshop in about 12 hours" do
        workshop.update_attribute(:start_time, (Event::FIRST_NOTIFICATION - 5.minutes).from_now)

        expect(Workshop.time_for_first_notification.to_a).to eql([workshop])
      end

      it "should not include a workshop in about 13 hours" do
        workshop.update_attribute(:start_time, (Event::FIRST_NOTIFICATION + 55.minutes).from_now)

        expect(Workshop.time_for_first_notification).to be_empty
      end

      it "should not include a workshop in about 11 and a half hours" do
        workshop.update_attribute(:start_time, (Event::FIRST_NOTIFICATION - 31.minutes).from_now)

        expect(Workshop.time_for_first_notification).to be_empty
      end

    end

    context "that need their last notification" do
      it "should include a workshop in about 4 hours" do
        workshop.update_attribute(:start_time, (Event::LAST_NOTIFICATION - 5.minutes).from_now)

        expect(Workshop.time_for_last_notification.to_a).to eql([workshop])
      end

      it "should not include a workshop in about 5 hours" do
        workshop.update_attribute(:start_time, (Event::LAST_NOTIFICATION + 55.minutes).from_now)

        expect(Workshop.time_for_last_notification).to be_empty
      end

      it "should not include a workshop in about 4 and a half hours" do
        workshop.update_attribute(:start_time, (Event::LAST_NOTIFICATION - 31.minutes).from_now)

        expect(Workshop.time_for_last_notification).to be_empty
      end

    end
  end

  context "finding group session invitations" do
    let(:group_session_invitation) { create(:group_session_invitation) }

    context "that need their first notification" do
      it "should include a group_session_invitation in about 12 hours" do
        group_session_invitation.update_attribute(:start_time, (Event::FIRST_NOTIFICATION - 5.minutes).from_now)

        expect(GroupSessionInvitation.time_for_first_notification.to_a).to eql([group_session_invitation])
      end

      it "should not include a group_session_invitation in about 13 hours" do
        group_session_invitation.update_attribute(:start_time, (Event::FIRST_NOTIFICATION + 55.minutes).from_now)

        expect(GroupSessionInvitation.time_for_first_notification).to be_empty
      end

      it "should not include a group_session_invitation in about 11 and a half hours" do
        group_session_invitation.update_attribute(:start_time, (Event::FIRST_NOTIFICATION - 31.minutes).from_now)

        expect(GroupSessionInvitation.time_for_first_notification).to be_empty
      end

    end

    context "that need their last notification" do
      it "should include a group_session_invitation in about 4 hours" do
        group_session_invitation.update_attribute(:start_time, (Event::LAST_NOTIFICATION - 5.minutes).from_now)

        expect(GroupSessionInvitation.time_for_last_notification.to_a).to eql([group_session_invitation])
      end

      it "should not include a workshop in about 5 hours" do
        group_session_invitation.update_attribute(:start_time, (Event::LAST_NOTIFICATION + 55.minutes).from_now)

        expect(GroupSessionInvitation.time_for_last_notification).to be_empty
      end

      it "should not include a workshop in about 4 and a half hours" do
        group_session_invitation.update_attribute(:start_time, (Event::LAST_NOTIFICATION - 31.minutes).from_now)

        expect(GroupSessionInvitation.time_for_last_notification).to be_empty
      end

    end
  end

end
