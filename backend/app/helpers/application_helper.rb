# app/helpers/application_helper.rb

module ApplicationHelper
    def color_for_background(background_color, threshold: 0.7)
      # Convert hex to RGB
      if background_color.start_with?('#')
        r, g, b = background_color[1..2].hex, background_color[3..4].hex, background_color[5..6].hex
      else
        # Assume already in RGB format or add additional parsing logic
        # This part is left as is for simplicity; adapt as needed
      end
  
      # Calculate luminance
      luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
  
      # Adjust the threshold as needed for your specific use case
      luminance > threshold ? '#000' : '#FFF'
    end
  end
  