class AnimalsController < ApplicationController
  def index
    @animals = Animal.order('created_at DESC')

      respond_to do |format|
        format.html
        format.zip do
          stringio = Zip::OutputStream.write_buffer do |zio|
            @animals.each do |animal|
              zio.put_next_entry "#{animal.name}-#{animal.id}.json"
              zio.print animal.to_json(only: [:name, :age, :species])

              dec_pdf = render_to_string :pdf => "#{animal.name}-#{animal.id}.pdf", :template => "animals/index.html.erb", :locals => {animal: animal}, :layouts => false
              zio.put_next_entry("#{animal.name}-#{animal.id}.pdf")
              zio << dec_pdf
            end
          end
          stringio.rewind
          binary_data = stringio.sysread
          send_data(binary_data, :type => 'application/zip', :filename => "animals.zip")
        end
      end
      
  end

  # def index
  #   @animals = Animal.order('created_at DESC')
  #   respond_to do |format|
  #     format.html
  #     format.zip do
  #       compressed_filestream = Zip::OutputStream.write_buffer do |zos|
  #         @animals.each do |animal|
  #           zos.put_next_entry "Bio.docx"
  #           zos.print "=====> NAME\n"
  #           zos.print animal.name
  #           zos.print "\n"
  #           zos.print "=====> SPECIES\n"
  #           zos.print animal.species
  #           zos.put_next_entry "#{animal.name}-#{animal.id}.json"
  #           zos.print animal.to_json(only: [:name, :age, :species])
  #         end
  #       end
  #       compressed_filestream.rewind
  #       send_data compressed_filestream.read, filename: "animals.zip"
  #     end
  #   end
  # end

  def show
    @animal = Animal.find_by(id: params[:id])

    respond_to do |format|
      format.html
      format.pdf do
        render pdf: "Animal #{@animal.id}",
        page_size: 'A4',
        template: "animals/show.html.erb",
        # layout: "pdf.html",
        orientation: "Landscape",
        lowquality: true,
        zoom: 1,
        dpi: 75
      end
    end
  end

  def new
    @animal = Animal.new
  end

  def create
    # byebug
    if params[:archive].present?
      Zip::File.open(params[:archive].tempfile) do |zip_file|
        zip_file.glob('*.json').each { |entry| Animal.from_json(entry) }
      end
    elsif params[:animal][:name] && params[:animal][:age] && params[:animal][:species]
      @animal = Animal.create(
        name: params[:animal][:name],
        age: params[:animal][:age],
        species: params[:animal][:species]
      )
    end
    redirect_to root_path
  end

end