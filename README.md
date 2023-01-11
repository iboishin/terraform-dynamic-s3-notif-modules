# Project context
This GitHub repo is a simplified version of a marketing data pipeline that I recently deployed on AWS. Once the pipeline was deployed, I wanted to optimize the code with Terraform modules to avoid code repetition and to promote maintainability. The file *main_v0.tf* is the basic Terraform deployement, while *main.tf* uses Terraform modules located in the folder *modules*. Both versions use the dummy python files located in *source*.

# Getting started
1. Install Terraform [(link)](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
2. Create an AWS account [(link)](https://aws.amazon.com/fr/premiumsupport/knowledge-center/create-and-activate-aws-account/)
3. Clone the repo
4. Explore the code

# Tips : How to write modules with conditional dynamic elements

When writing code, the DRY principle is one of the first ones that we are taught to respect. Terraform modules aim to do just that : package repeatable code so that you, as the coder, Don't Repeat Yourself.

Here is the architecture for this project :

![Alt Image](project-architecture.drawio.png)


# To do
3. Finish lesson 5
4. Add code snippets and concrete examples

With this simple example, my aim is to demonstrate the power of Terraform (TF) modules, when you know how to use them appropriately. Here are my five pieces of advice for data engineers who are starting out.

# 1. As your architecture grows, organize your code
When I first started using Terraform, I thought that it was brilliant. No need to go into the console and spend time clicking on options when I could easily define them through simple TF code. As my architecture grew, I started to spend more and more time trying to locate the resource that I wanted to update in my infrastructure. While we generally start out with only one .tf file, as you deploy more and more resources, consider splitting those files up by service. Terraform does not care whether you have one .tf file or many. During the deployment process, it simply concatenates all of the .tf files in the folder. If you need one resource to be deployed before another, add a depends_on clause to that resource because the order that you define the resources in your code is not necessarily the order in which Terraform will deploy them.

# 2. Group resources into logical modules
As my code base grew, I also noticed that I was doing a lot of copy and pasting to create new resources, and more specifically that I was copying and pasting the same group of tightly coupled resources. This was definitely not the most efficient way of doing this, given that it did not respect the basic DRY principle. After some research, I came across modules. Modules are groups of resources that you define in order to be able to call and deploy together. So, I set about defining the use cases that would require code and infrastructure evolution in order to determine which resources are generally used together and would thus make sense to group together in a module.

This was not a simple task as some resources, like the s3 bucket notification and the lambda function below are deployed at the same time.

Nevertheless, there is only one s3 bucket resource and all of the s3 bucket notifications must be deployed within that resource. As a result, the s3 bucket notification has to simply be added to the existing s3 bucket resource below.

For this reason, I decided to group the code and lambda function resources into one module, while keeping the s3 notification separate (and in the back of my mind for further optimisations).


# 3. Create modules for repetitive blocs as you go
While it is recommended for versioning purposes, modules do not have to be published in a repo separate from your project. As you are adding elements to your architecture, create a 'modules' directory to group relevant resources together as you go. Once you start to have a significant amount of modules and you would like to use different versions, create a separate repo for these modules.

Why use different versions of modules ? If you would like to evolve your module but it is currently being used in production, you can tag the commit used in production and continue to use that module version for those resources. Meanwhile, you can continue development on your module and test it on a development environment using a different tag. Once the module is updated and stable, update the module tag for the production environment. In this way, you keep all of the version history of a module together and avoid testing the module changes in production.

# 4. Take advantage of for loops and conditionals
Once I decided which resources to group together, I noticed that *within* several resources, I had several repeating blocs, most notably in the s3 notifications. As explained in section 3, when I add a new use case, a new s3 bucket notification needs to be added as well. Creating a for_each to loop through a list of my various s3 bucket notifications solved the problem in a very straightforward way. But what about when I include another type of notification : sns_topics ? How do I take care of a case where I have one bucket with only s3 notifications and another with both s3 and sns notifications ? What about buckets that don't have any notifications ? How do I deal with sns notifications that require only one bloc for the notifications but multiple lambda permissions ? How do I create simple, logical and error proof variables ? (i.e. not having to repeat a list of lambdas for the sns notifications and a dictionary for the lambda permissions)

I often find that when I have a tech issue, I try to foresee all of the issues that I will have. This can be overwhelming. In those moments, I break down my problem and try to solve a small issue at a time. After a couple iterations, I find that the problem has been resolved with no major concerns just by approaching it in an iterative manner. This approach relies heavily on testing as you go to ensure that one issue is resolved correctly before going on to the next, in order to avoid an overwhelming list of errors at a time.

After I created and tested the for_each for the s3 notifications. I tried creating the sns notifications. They were a bit more complicated because they did not have a one to one s3-lambda relationship. As a result, I could not have a simple list. I needed to use something like a dictionary with the lambdas as the keys and sns topic as the value. After a bit of trial and error, that question was answered as well.

Once the separate elements were answered, I came to the question that worried me the most : how do I tell TF to deploy an s3 bucket with no notifications but also an s3 bucket with only s3 notifications and a third bucket with both types of notifications ? Again, I took a breath and instead of worrying for no reason, I started to test different options.

# 5. Get creative but remain simple
Finding a way to include a conditional bloc with a repeating element stumped me at the beginning. How would that be possible when I couldn't use both a for_each and a count statement within my resource specification. As always, I turned to the power of the collective mind : Google. Reading through a couple peoples' problems, I combined multiple replies to come up with the conditional for_each statement. Initially, I was worried that it would not work because I figured that Terraform would still try to create a resource even if the input each.value is empty. Instead of worrying about that, I tested it. And it worked. Yet, it was not the simplest solution. I realized that by simply specifying and empty list as my default for the variable in my variables.tf file, I could do away with the conditional statement all together.

Just because a functionality like conditional statements is available however, does not mean that it is always the best solution. My advice, not only applicable to code, is to define your need and to start by solving it. Once you have solved the need, see if you can optimize and simplify the solution. Code is already hard to read and make sense of several months after you write it, no need to complicate it further and make it completely uncomprehensible.

## Special thanks
*Shout out to Yevgeniy Brikman who wrote the two most useful Terraform module articles (see PDFs) that I have read.*