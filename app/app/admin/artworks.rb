ActiveAdmin.register Artwork do
  menu priority: 1, label: "Artworks"
  permit_params :image, :video

  form do |f|
    f.inputs 'Artwork Details' do
      f.input :image, as: :file, hint: f.object.image.attached? ? image_tag(url_for(f.object.image)) : content_tag(:span, "No image available")
      f.input :video, as: :file, hint: f.object.video.attached? ? video_tag(url_for(f.object.video), controls: true) : content_tag(:span, "No video available")
    end

    f.actions
  end


  index as: :grid do |artwork|
    div for: artwork, class: "artwork-grid-item", style: "cursor: pointer;" do
      # Using div with onclick event to handle navigation
      link_path = admin_artwork_path(artwork)

      if artwork.image.attached?
        div onclick: "window.location='#{link_path}'" do
          image_tag artwork.image, style: "height: 200px; width: 200px; display: block; margin: auto;"
        end
      elsif artwork.video.attached?
        div onclick: "window.location='#{link_path}'" do
          video controls: false, style: "max-width: 200px; max-height: 200px; display: block; margin: auto;" do
            source src: url_for(artwork.video), type: 'video/mp4'
          end
        end
      end
      # Display the title
      h3 artwork.title, style: "text-align: center;"
    end
  end

  show do
    attributes_table do
      row :title
      row :image do |artwork|
        if artwork.image.attached?
          image_tag artwork.url
        end
      end
      row :video do |artwork|
        if artwork.video.attached?
          video_tag artwork.url, controls: true
        end
      end
    end
  end
end
