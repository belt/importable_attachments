class @ProjectPage
  download_icon: ->
    jQuery('#icon_file_download')

  upload_icon: ->
    jQuery('#icon_file_upload')

  input_file_field: ->
    jQuery('#attachment_attributes_io_stream_fields input[id$=_io_stream][type=file]')

  upload_form: ->
    jQuery('#contents form:first')

  file_name_label: ->
    jQuery('#file_name')

  hide_upload_field: ->
    jQuery('#attachment_attributes_io_stream_fields li[id$=_io_stream_input]').addClass('visually_hidden')

  bind_upload_icon_to_file_field: ->
    @upload_icon().click ->
      page = new ProjectPage
      file_field = page.input_file_field()
      file_field.click()
      file_field.change ->
        page.file_name_label().text(jQuery(@).val().replace("C:\\fakepath\\", ""))
        page.upload_form().find('input[type=submit]').click()

  drop_new_form_faux_link: ->
    @download_icon().removeClass 'faux_link' if @upload_form().attr('id') is 'new_attachment'

  hide_new_form_download_icon: ->
    @download_icon().hide() if @upload_form().attr('id') is 'new_attachment'

jQuery(document).ready ->
  page = new ProjectPage
  page.hide_upload_field()
  page.bind_upload_icon_to_file_field()
  page.drop_new_form_faux_link()
  page.hide_new_form_download_icon()

