require "sinatra"
require 'sinatra/flash'
require_relative "authentication.rb"
require_relative "upgrade.rb"
require_relative "school.rb"
require_relative "teacher.rb"
require_relative "review.rb"

# the following urls are included in authentication.rb
# GET /login
# GET /logout
# GET /sign_up

if User.all(type: 3).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.type = 3
	u.save
end

# authenticate! will make sure that the user is signed in, if they are not they will be redirected to the login page
# if the user is signed in, current_user will refer to the signed in user object.
# if they are not signed in, current_user will be nil

get "/" do
	erb :index
end

get "/schools" do
	authenticate!
	@schools = School.all
	erb :schools
end

get("/schools/teachers/:id") do
	authenticate!
	@teachers = Teacher.all(Teacher.school_id => params[:id].to_i)
	erb :teachers
end


get("/schools/teachers/:id/:name") do
	authenticate!
	if pro_user || admin
		puts "This is the id we are searching for: #{params[:id]}"
		@teacher = Teacher.first(:id => params[:id].to_i)
		@reviews = Review.all(Review.teacher_id => params[:id].to_i)
		erb :reviews
	else
		redirect '/upgrade'
	end
end

post "/create_review" do
	teach = Teacher.first(:id => params[:teacher].to_i)
	if params[:teacher] && params[:rating] && params[:textReview]
		rev = Review.new 
		rev.review = params[:textReview]
		rev.rating = params[:rating].to_i
		rev.user_id = current_user.id
		rev.teacher_id = teach.id
		rev.school_id = teach.school_id

		rev.save

		#Update the teacher ratings
		currentRating = teach.totalRatings
		currentSum = teach.totalSum
		teach.update(:totalRatings => currentRating + params[:rating].to_i)
		teach.update(:totalSum => currentSum + 1)
		teach.save

		#Update the school ratings
		sch = School.first(:id => teach.school_id)
		schRating = sch.totalRatings
		schSum = sch.totalSum
		sch.update(:totalRatings => schRating + params[:rating].to_i)
		sch.update(:totalSum => schSum + 1)
		sch.save

		flash[:success] = "Review has been added"
	else
		flash[:error] = "Parameters are needed"
	end

	redirect "/schools/teachers/#{teach.id}/#{teach.name}" 


end


get "/schools/new" do
	authenticate!
	if admin
		@schools = School.all
		erb :new
	else
		redirect "/"
	end
end

post "/schools/create_school" do
	authenticate!
	if params[:school_name] 
		sch = School.new
		sch.name = params[:school_name]
		sch.save
		flash[:success] = "Succesfully Added #{sch.name}"
	end
	
	redirect"/schools/new"
end

post "/schools/create_teacher" do
	if params[:teacher_name] && params[:select_school]
		tch = Teacher.new
		tch.name = params[:teacher_name]
		t = School.first(:name => params[:select_school])
		tch.school_id = t.id
		tch.save
		flash[:success] = "Succesfully Added #{tch.name} with id #{tch.id}"
	end

	redirect"/schools/new"
end


get "/reviews" do
	authenticate!
	erb :reviews
end