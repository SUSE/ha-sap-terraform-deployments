# frozen_string_literal: true

class SourcesController < ApplicationController
  include Exportable
  before_action :set_sources, only: [:index, :show, :new, :edit]
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  # GET /sources
  def index; end

  # GET /sources/1
  def show; end

  # GET /sources/new
  def new
    @source = Source.new
  end

  # GET /sources/1/edit
  def edit; end

  # POST /sources
  def create
    @source = Source.new(source_params)

    if @source.save
      message = 'Source was successfully created.'
      flash = { notice: message }
      redirect_to edit_source_path(@source), flash: flash
    else
      set_sources
      return render :new
    end
  end

  # PATCH/PUT /sources/1
  def update
    if @source.update(source_params)
      message = 'Source was successfully updated.'
      flash = { notice: message }
      redirect_to edit_source_path, flash: flash
    else
      set_sources
      render :new
    end
  end

  # DELETE /sources/1
  def destroy
    @source.destroy
    redirect_to(sources_path, notice: 'Source was successfully destroyed.')
  end

  def validate_terra
    validation = Source.valid_sources

    if validation
      flash[:error] = validation
    else
      flash[:notice] = 'All sources are valid.'
    end

    redirect_to request.referer
  end

  private

  def set_sources
    terra = Terraform.new
    validation = terra.validate(true, true)
    flash.now[:error] = validation if validation

    @sources = Source.all.order(:filename)
  end

  def set_source
    terra = Terraform.new
    validation = terra.validate(true, true)
    flash.now[:error] = validation if validation
    @source = Source.find(params[:id])
  end

  def source_params
    params.require(:source).permit(:filename, :content)
  end
end
