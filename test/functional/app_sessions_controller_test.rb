require 'test_helper'

class AppSessionsControllerTest < ActionController::TestCase
  setup do
    @app_session = app_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_session" do
    assert_difference('AppSession.count') do
      post :create, app_session: @app_session.attributes
    end

    assert_redirected_to app_session_path(assigns(:app_session))
  end

  test "should show app_session" do
    get :show, id: @app_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @app_session
    assert_response :success
  end

  test "should update app_session" do
    put :update, id: @app_session, app_session: @app_session.attributes
    assert_redirected_to app_session_path(assigns(:app_session))
  end

  test "should destroy app_session" do
    assert_difference('AppSession.count', -1) do
      delete :destroy, id: @app_session
    end

    assert_redirected_to app_sessions_path
  end
end
