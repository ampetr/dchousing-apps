class ApplicationController < ActionController::Base
  protect_from_forgery

  private

  def generate_pdf_archive forms, applicant
    stringio = Zip::OutputStream::write_buffer do |zio|
      forms.each do |form|
        filled_form = OutputPDF.new(form, applicant).to_file
        zio.put_next_entry(form.name)
        zio.write(filled_form.read)
        filled_form.unlink
      end
    end
    stringio.rewind
    stringio.sysread
  end

  def current_applicant
    current_user.applicants.first_or_create.tap do |applicant|
      applicant.create_identity if applicant.identity.nil?
      applicant.save
    end
  end
end
