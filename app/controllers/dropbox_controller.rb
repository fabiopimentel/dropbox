require 'fileutils'
class DropboxController < ApplicationController
  TMP_DIR = File.join(Rails.root, "tmp")
  DROPBOX_DIR = File.join(TMP_DIR,"dropbox/")

 def index
   # @filebox = Filebox.new
  end       

  def authorize
    if params[:oauth_token] then
      dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
      dropbox_session.authorize(params)
      session[:dropbox_session] = dropbox_session.serialize # re-serialize the authenticated session       

      redirect_to :action => 'upload'
    else
      dropbox_session = Dropbox::Session.new('vsrsqdsh5da2i9y', 'bkvn1v6cnispnj7')
      session[:dropbox_session] = dropbox_session.serialize
      redirect_to dropbox_session.authorize_url(:oauth_callback => url_for(:action => 'authorize'))
    end
  end

  def upload
    return redirect_to(:action => 'authorize') unless session[:dropbox_session]
    dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
    return redirect_to(:action => 'authorize') unless dropbox_session.authorized?

    if request.method == 'POST' then
      dropbox_session.mode = :dropbox
      dropbox_session.upload  params[:file].tempfile, 'RCase',{:as=>params[:file].original_filename}
      render :text => 'Uploaded OK'  
    else
      redirect_to(:action => 'index', :notice => 'Upload Fail')
    end
  end
  
  def lista
  	return redirect_to(:action => 'authorize') unless session[:dropbox_session]
    dropbox_session = Dropbox::Session.deserialize(session[:dropbox_session])
    return redirect_to(:action => 'authorize') unless dropbox_session.authorized?
       if request.method == 'GET' then
      dropbox_session.mode = :dropbox
    	arquivos= dropbox_session.list("RCase")
      file = dropbox_session.download("RCase/teste.zip")
    	p file
    	#arquivos.each {|x| print x.path,dropbox_session.download(x.path)}
      render :text => 'Downloaded OK'  
    else
      redirect_to(:action => 'index', :notice => 'Download Fail')
    end
    
  
  end
end
