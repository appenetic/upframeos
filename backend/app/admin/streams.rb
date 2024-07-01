ActiveAdmin.register Stream do
  menu priority: 2, label: "Art Streams"
  permit_params :title, :icon_url

end
