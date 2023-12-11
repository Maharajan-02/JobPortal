// SPDX-License-Identifier: GPL-3.0


//git-hub : https://github.com/Maharajan-02/JobPortal.git

pragma solidity > 0.8.0;

contract Job_Portal{

    address payable admin;
    uint _job_id;
    uint appl_id;
    uint total_no_of_applicants;
    uint total_no_of_jobs;

    enum ApplicantType {PartTime, FullTime, Contract}

    struct Applicants{
        uint applicant_id;
        address eth_address;
        string applicant_name;
        string applicant_address;
        string applicant_email_id;
        ApplicantType applicant_Type;
        string applicant_phone_number;
        uint8 current_salary;
        uint8 expected_salary;
        uint applicant_rating;
        uint no_of_rating;
    }

    struct userId{
        uint id;
    }

    struct Applicant_qualification{
        string course_name;
        string degree;
        uint duration;
        uint percentage;
    }

    struct Previous_Experiance{
        string company_name;
        string Job_Role;
        uint8 years_of_experiance;
    }

    struct Known_Techs{
        string tech_name;
        uint8 exp_on_tech;
    }

    struct Job_Post{
        address job_eth_address;
        uint job_id;
        string Role;
        string job_description;
        uint number_of_opening;
        ApplicantType applicant_type;
        uint8 required_years_of_experiance;
        uint total_rating;
        uint num_of_ratings;
        bool job_posted;
    }

    struct ContactDetails{ //To reduce the parameter size of a struct
        string company_name;
        string job_location;
        string comapany_mail;
        string company_phone;
        string Industry_type;
    }

    struct Required_Techs{
        string tech_names;
    }

    struct Good_To_Have_Techs{
        string tech_names;
    }
    
    //Mapping declatration
    mapping (uint => Applicants) applicantDetails;
    mapping (uint => Applicant_qualification[]) applicantQualification;
    mapping (uint => Previous_Experiance[]) previousExperiance;
    mapping (uint => Known_Techs[]) knownTechs;
    mapping (uint => Job_Post) jobPost;
    mapping (uint => Required_Techs[]) requiredTechs;
    mapping (uint => Good_To_Have_Techs[]) goodToHaveTechs;
    mapping (address => userId) user_id;
    mapping (uint => ContactDetails) contactDetails;

   //Event Declaration 
    event applicant_registered_success(address _address);
    event qualification_added(uint indexed applicant_id);
    event experiance_added(uint indexed applicant_id);
    event job_added(uint indexed job_id, address indexed job_owner, string job_title);
    event techs_added(address indexed owner, string tech_name);

  
    constructor(){
        admin = payable(msg.sender);
        _job_id = 0;
        appl_id = 0;
        total_no_of_applicants = 0;
        total_no_of_jobs = 0;
    }

    modifier onlyJobOwner(uint job_id) {
        require(msg.sender == jobPost[job_id].job_eth_address, "Only job owner can modify.");
        _;
    }

    modifier  validApplicantID(uint id){
        require(id > 0 && id < total_no_of_applicants, "Invalid job Id.");
        _;
    }

    modifier firstTimeRegistration(){
        require(user_id[msg.sender].id == 0, "You have already registered as an applicant in the Job Portal.");
        _;
    }

    modifier is_applicant(uint id){
        require(msg.sender == applicantDetails[id].eth_address, "You can't modify for this Id.");
        _;
    }

    function register(string memory name, string memory _address, string memory email_id, string memory phone_number, ApplicantType applicant_type,
        uint8 current_salary_in_LPA, uint8 expected_salary_in_LPA) public firstTimeRegistration{
            uint id = ++appl_id;
            Applicants memory new_applicant = Applicants(id, msg.sender, name, _address, email_id, applicant_type, phone_number,current_salary_in_LPA, expected_salary_in_LPA, 0, 0);
            applicantDetails[id] = new_applicant;
            emit applicant_registered_success(msg.sender);
            total_no_of_applicants += 1;
    }

    function add_qualififcation(uint id, string memory _course_name, string memory _degree, uint _duration, uint _percentage) public is_applicant(id){
        applicantQualification[id].push(
            Applicant_qualification(_course_name, _degree, _duration, _percentage)
            );
        emit qualification_added(id);
    }

    function add_experiance(uint id, string memory _company_name, string memory _role, uint8 _years_of_experiance) public is_applicant(id){
        previousExperiance[id].push(
            Previous_Experiance(_company_name, _role, _years_of_experiance)
        );
        emit experiance_added(id);
    }

    function add_techs(uint id, string memory _tech_name, uint8 _years_of_experiance) public is_applicant(id){
        knownTechs[id].push(
            Known_Techs(_tech_name, _years_of_experiance)
        );
        emit techs_added(msg.sender, _tech_name);
    }

    function get_applicant_detail(uint id) public view validApplicantID (id) returns (Applicants memory) {
        return applicantDetails[id];
    }

    function get_applicant_type(uint id) public view validApplicantID (id) returns (ApplicantType){
        return applicantDetails[id].applicant_Type;
    }

    function rate_applicant(uint id, uint rating) public validApplicantID(id){
        require(rating > 0 && rating <= 5,"Invalid rating");
        applicantDetails[id].applicant_rating += rating;
    }

    function get_applicant_rating(uint _id) public view returns (uint) {
       uint totalRating = applicantDetails[_id].applicant_rating;
    uint numOfRatings = applicantQualification[_id].length;

    if (numOfRatings > 0) {
        return totalRating / numOfRatings;
    } else {
        return 0;
    }
    }

   function add_new_job(string memory _role, string memory _description, uint _number_of_opening, string memory _company_name, string memory _location, string memory _mail, string memory _phone, ApplicantType _applicant_type, uint8 _required_exp, string memory _industry_type) public{
        uint id = ++_job_id;
        Job_Post memory newJob = Job_Post(msg.sender, id, _role, _description, _number_of_opening, _applicant_type, _required_exp, 0, 0, false);
        jobPost[id] = newJob; 
        add_contact_details(id, _company_name, _location, _mail, _phone, _industry_type);
        emit job_added(id, msg.sender, _role);
        total_no_of_jobs ++;
    }

    function add_contact_details(uint job_id, string memory _name, string memory _location, string memory _mail, string memory _phone, string memory _industry_type) internal {
        contactDetails[job_id] = ContactDetails(_name, _location, _mail, _phone, _industry_type);
    }

    function add_required_tech(uint job_id, string memory tech_name) public onlyJobOwner(job_id){
        requiredTechs[job_id].push(
            Required_Techs(tech_name)
        );
        emit techs_added(msg.sender, tech_name);
    }

    function add_good_to_have_tech(uint job_id, string memory tech_name) public onlyJobOwner(job_id){
        goodToHaveTechs[job_id].push(
            Good_To_Have_Techs(tech_name)
        );
        emit techs_added(msg.sender, tech_name);
    }

    function get_job_details(uint job_id) public view returns(Job_Post memory, ContactDetails memory, Required_Techs[] memory, Good_To_Have_Techs[] memory){
        return(jobPost[job_id], contactDetails[job_id], requiredTechs[job_id], goodToHaveTechs[job_id]);
    }

    function rate_job(uint job_id, uint8 rating) public{
        require(jobPost[job_id].job_id != 0, "Job does not exist");
        require(rating > 0 && rating <= 5, "Invalid rating");
        
        jobPost[job_id].total_rating += rating;
        jobPost[job_id].num_of_ratings++;
    }

    function get_job_rating(uint job_id) public view returns(uint){
       if (jobPost[job_id].num_of_ratings > 0) {
            return jobPost[job_id].total_rating / jobPost[job_id].num_of_ratings;
        } else {
            return 0; // or handle this case appropriately
        }
    }

    function post_job_online(uint job_id) public onlyJobOwner(job_id){
        require(requiredTechs[job_id].length > 0, "Required techs must be specified before posting the job");
        jobPost[job_id].job_posted = true;
    }

    function remove_job_online(uint job_id) public onlyJobOwner(job_id){
        jobPost[job_id].job_posted = false;
    }
}