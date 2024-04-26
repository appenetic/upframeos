ActiveAdmin.register Artwork do
  menu priority: 1, label: "Artworks"
  permit_params :asset, :fill_mode

  form do |f|
    f.inputs 'Artwork Details' do
      if f.object.asset.attached?
        if f.object.is_image?
          f.input :asset, as: :file, hint: image_tag(url_for(f.object.asset))
        elsif f.object.is_video?
          video_tag url_for(f.object.asset), controls: true, style: "max-width: 400px; max-height: 400px; display: block; margin: auto;"
        else
          f.input :asset, as: :file, hint: content_tag(:span, "No image or video available")
        end
      else
        f.input :asset, as: :file, hint: content_tag(:span, "No asset attached")
      end
    end

    f.input :fill_mode, as: :select, collection: Artwork.fill_modes.keys.map { |mode| [mode.titleize, mode] }, include_blank: false

    f.actions
  end

  index as: :grid do |artwork|
    div for: artwork, class: "artwork-grid-item", style: "cursor: pointer;" do
      # Using div with onclick event to handle navigation
      link_path = admin_artwork_path(artwork)

      if artwork.is_video?
        div onclick: "window.location='#{link_path}'" do
          video controls: false, style: "max-width: 200px; max-height: 200px; display: block; margin: auto;" do
            source src: artwork.url, type: 'video/mp4'
          end
        end

      elsif artwork.is_image?
        div onclick: "window.location='#{link_path}'" do
          image_tag artwork.url, style: "#{artwork.fill_mode == 'fit_screen' ? 'max-height: 200px; max-width: 200px;' : 'height: 200px; width: 200px;'} display: block; margin: auto;"
        end
      end
    end
  end

  show do
    attributes_table do
      row :asset do |artwork|
        if artwork.is_image?
          image_tag artwork.url, style: "#{artwork.fill_mode == 'fit_screen' ? 'max-height: 400px; max-width: 400px;' : 'height: 400px; width: 400px;'}"
        elsif artwork.is_video?
          video_tag artwork.url, controls: true
        end
      end
      row :fill_mode
    end
  end
end
