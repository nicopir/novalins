require 'test_helper'

class OutputFilesControllerTest < ActionController::TestCase
  setup do
    @output_file = output_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:output_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create output_file" do
    assert_difference('OutputFile.count') do
      post :create, output_file: { file_path: @output_file.file_path, name: @output_file.name, project_id: @output_file.project_id }
    end

    assert_redirected_to output_file_path(assigns(:output_file))
  end

  test "should show output_file" do
    get :show, id: @output_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @output_file
    assert_response :success
  end

  test "should update output_file" do
    patch :update, id: @output_file, output_file: { file_path: @output_file.file_path, name: @output_file.name, project_id: @output_file.project_id }
    assert_redirected_to output_file_path(assigns(:output_file))
  end

  test "should destroy output_file" do
    assert_difference('OutputFile.count', -1) do
      delete :destroy, id: @output_file
    end

    assert_redirected_to output_files_path
  end
end
