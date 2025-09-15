# Salesforce Queueable Job Chain Library

<span>
  <img
    alt="RestFramework - Salesforce Apex REST Framework"
    src="assets/small_logo.png"
    height="28px"
  >
</span>
<a href="https://githubsfdeploy.herokuapp.com?owner=akohan91&repo=Libak_RestFramework&ref=main">
  <img
    alt="Deploy to Salesforce"
    src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png"
    height="28px"
  >
</a>
<a href="https://www.linkedin.com/pulse/mastering-rest-framework-building-robust-restful-web-apex-andrei-wefqe">
  LinkedIn
</a>

A lightweight and flexible library for implementing chainable queueable jobs in Salesforce with built-in retry capabilities and error handling.

## 💡 Features

- Chain multiple queueable jobs sequentially
- Automatic retry mechanism for failed jobs
- Built-in finalizer for handling job completion and failures
- Singleton pattern to maintain job chain state
- Thread-safe implementation


## Usage

### Basic Example

```java
// Create a concrete implementation
public class MyJob extends QueueableJob {
    protected override void doExecute(QueueableContext context) {
        // Your job logic here
    }
}

// Chain and execute jobs
QueueableJob.instance
    .addJob(new MyJob().setMaxRetries(3))
    .addJob(new AnotherJob().setMaxRetries(3))
    .enqueueJobs();
```

### Retry Mechanism

Jobs will automatically retry on failure based on the specified retry count:

```java
QueueableJob.instance
    .addJob(new MyJob().setMaxRetries(3)) // Will retry up to 3 times on failure
    .enqueueJobs();
```

## API Reference

### Methods

- `addJob(QueueableJob job)`: Adds a single job to the chain
- `addJobs(List<QueueableJob> jobs)`: Adds multiple jobs to the chain
- `setMaxRetries(Integer maxRetries)`: Sets the maximum retry attempts
- `enqueueJobs()`: Starts the job chain execution

### Protected Methods

- `doExecute(QueueableContext context)`: Override this method in your concrete implementation


## 🤝 Contribution

We welcome contributions! Here’s how you can get started:

1. **🍴 Fork the Repository**

2. **🌱 Create a New Branch**

Work on your changes in a separate branch.

Follow the branch naming conventions:

- ✨ For features: `feature/<branch-name>`
- 🐛 For bug fixes: `bugfix/<branch-name>`
- 📚 For documentation: `doc/<branch-name>`

3. **🔧 Make Changes and Test**

Implement your changes and ensure everything works.

4. **🚀 Push Your Changes**

Push your branch to your forked repository:

`git push origin your-branch-name`

5. **📬 Submit a Pull Request**

Open a pull request to the develop branch with a clear description of your changes.


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 📧 Contact

Have questions or feedback? Reach out to the repository owner or start a discussion in the Issues tab.
