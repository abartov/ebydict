# frozen_string_literal: true

module ImageHelpers
  # Generate a simple test image using RMagick
  def self.generate_test_image(width: 100, height: 100, text: 'Test', format: 'JPEG')
    require 'rmagick'

    image = Magick::Image.new(width, height) do |img|
      img.background_color = 'white'
    end

    # Add text to make it identifiable
    text_image = Magick::Draw.new
    text_image.annotate(image, 0, 0, 0, 0, text) do |txt|
      txt.gravity = Magick::CenterGravity
      txt.pointsize = 20
      txt.fill = 'black'
    end

    # Return as blob
    image.format = format
    image.to_blob
  end

  # Create test image fixtures at boot
  def self.setup_test_images
    fixtures_dir = Rails.root.join('spec', 'fixtures', 'images')
    FileUtils.mkdir_p(fixtures_dir)

    # Generate standard test images if they don't exist
    {
      'scan_100x100.jpg' => { width: 100, height: 100, text: 'Scan' },
      'column_80x150.jpg' => { width: 80, height: 150, text: 'Col' },
      'def_part_80x50.jpg' => { width: 80, height: 50, text: 'Def' },
      'small_50x50.jpg' => { width: 50, height: 50, text: 'S' }
    }.each do |filename, opts|
      filepath = fixtures_dir.join(filename)
      unless File.exist?(filepath)
        File.write(filepath, generate_test_image(**opts), mode: 'wb')
      end
    end
  end
end

# Generate test images once before the suite runs
RSpec.configure do |config|
  config.before(:suite) do
    ImageHelpers.setup_test_images
  end
end
