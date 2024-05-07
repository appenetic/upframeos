# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 0, label: proc { I18n.t("active_admin.dashboard") }, if: proc { true }

  content title: proc { I18n.t("active_admin.dashboard") } do
    render partial: 'layouts/admin/dashboard'
  end

  controller do

  end
end