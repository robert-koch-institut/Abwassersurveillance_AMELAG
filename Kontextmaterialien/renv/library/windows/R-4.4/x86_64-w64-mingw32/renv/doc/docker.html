<!DOCTYPE html>

<html>

<head>

<meta charset="utf-8" />
<meta name="generator" content="pandoc" />
<meta http-equiv="X-UA-Compatible" content="IE=EDGE" />

<meta name="viewport" content="width=device-width, initial-scale=1" />



<title>Using renv with Docker</title>

<script>// Pandoc 2.9 adds attributes on both header and div. We remove the former (to
// be compatible with the behavior of Pandoc < 2.8).
document.addEventListener('DOMContentLoaded', function(e) {
  var hs = document.querySelectorAll("div.section[class*='level'] > :first-child");
  var i, h, a;
  for (i = 0; i < hs.length; i++) {
    h = hs[i];
    if (!/^h[1-6]$/i.test(h.tagName)) continue;  // it should be a header h1-h6
    a = h.attributes;
    while (a.length > 0) h.removeAttribute(a[0].name);
  }
});
</script>

<style type="text/css">
code{white-space: pre-wrap;}
span.smallcaps{font-variant: small-caps;}
span.underline{text-decoration: underline;}
div.column{display: inline-block; vertical-align: top; width: 50%;}
div.hanging-indent{margin-left: 1.5em; text-indent: -1.5em;}
ul.task-list{list-style: none;}
</style>







<style type="text/css">body {
background-color: #fff;
margin: 1em auto;
max-width: 700px;
overflow: visible;
padding-left: 2em;
padding-right: 2em;
font-family: "Open Sans", "Helvetica Neue", Helvetica, Arial, sans-serif;
font-size: 14px;
line-height: 1.35;
}
#TOC {
clear: both;
margin: 0 0 10px 10px;
padding: 4px;
width: 400px;
border: 1px solid #CCCCCC;
border-radius: 5px;
background-color: #f6f6f6;
font-size: 13px;
line-height: 1.3;
}
#TOC .toctitle {
font-weight: bold;
font-size: 15px;
margin-left: 5px;
}
#TOC ul {
padding-left: 40px;
margin-left: -1.5em;
margin-top: 5px;
margin-bottom: 5px;
}
#TOC ul ul {
margin-left: -2em;
}
#TOC li {
line-height: 16px;
}
table {
margin: 1em auto;
border-width: 1px;
border-color: #DDDDDD;
border-style: outset;
border-collapse: collapse;
}
table th {
border-width: 2px;
padding: 5px;
border-style: inset;
}
table td {
border-width: 1px;
border-style: inset;
line-height: 18px;
padding: 5px 5px;
}
table, table th, table td {
border-left-style: none;
border-right-style: none;
}
table thead, table tr.even {
background-color: #f7f7f7;
}
p {
margin: 0.5em 0;
}
blockquote {
background-color: #f6f6f6;
padding: 0.25em 0.75em;
}
hr {
border-style: solid;
border: none;
border-top: 1px solid #777;
margin: 28px 0;
}
dl {
margin-left: 0;
}
dl dd {
margin-bottom: 13px;
margin-left: 13px;
}
dl dt {
font-weight: bold;
}
ul {
margin-top: 0;
}
ul li {
list-style: circle outside;
}
ul ul {
margin-bottom: 0;
}
pre, code {
background-color: #f7f7f7;
border-radius: 3px;
color: #333;
white-space: pre-wrap; 
}
pre {
border-radius: 3px;
margin: 5px 0px 10px 0px;
padding: 10px;
}
pre:not([class]) {
background-color: #f7f7f7;
}
code {
font-family: Consolas, Monaco, 'Courier New', monospace;
font-size: 85%;
}
p > code, li > code {
padding: 2px 0px;
}
div.figure {
text-align: center;
}
img {
background-color: #FFFFFF;
padding: 2px;
border: 1px solid #DDDDDD;
border-radius: 3px;
border: 1px solid #CCCCCC;
margin: 0 5px;
}
h1 {
margin-top: 0;
font-size: 35px;
line-height: 40px;
}
h2 {
border-bottom: 4px solid #f7f7f7;
padding-top: 10px;
padding-bottom: 2px;
font-size: 145%;
}
h3 {
border-bottom: 2px solid #f7f7f7;
padding-top: 10px;
font-size: 120%;
}
h4 {
border-bottom: 1px solid #f7f7f7;
margin-left: 8px;
font-size: 105%;
}
h5, h6 {
border-bottom: 1px solid #ccc;
font-size: 105%;
}
a {
color: #0033dd;
text-decoration: none;
}
a:hover {
color: #6666ff; }
a:visited {
color: #800080; }
a:visited:hover {
color: #BB00BB; }
a[href^="http:"] {
text-decoration: underline; }
a[href^="https:"] {
text-decoration: underline; }

code > span.kw { color: #555; font-weight: bold; } 
code > span.dt { color: #902000; } 
code > span.dv { color: #40a070; } 
code > span.bn { color: #d14; } 
code > span.fl { color: #d14; } 
code > span.ch { color: #d14; } 
code > span.st { color: #d14; } 
code > span.co { color: #888888; font-style: italic; } 
code > span.ot { color: #007020; } 
code > span.al { color: #ff0000; font-weight: bold; } 
code > span.fu { color: #900; font-weight: bold; } 
code > span.er { color: #a61717; background-color: #e3d2d2; } 
</style>




</head>

<body>




<h1 class="title toc-ignore">Using renv with Docker</h1>



<p>While renv can help capture the state of your R library at some point
in time, there are still other aspects of the system that can influence
the run-time behavior of your R application. In particular, the same R
code can produce different results depending on:</p>
<ul>
<li>The operating system in use,</li>
<li>The compiler flags used when R and packages are built,</li>
<li>The LAPACK / BLAS system(s) in use,</li>
<li>The versions of system libraries installed and in use,</li>
</ul>
<p>And so on. <a href="https://www.docker.com/">Docker</a> is a tool
that helps solve this problem through the use of
<strong>containers</strong>. Very roughly speaking, one can think of a
container as a small, self-contained system within which different
applications can be run. Using Docker, one can declaratively state how a
container should be built (what operating system it should use, and what
system software should be installed within), and use that system to run
applications. (For more details, please see <a href="https://environments.rstudio.com/docker" class="uri">https://environments.rstudio.com/docker</a>.)</p>
<p>Using Docker and renv together, one can then ensure that both the
underlying system, alongside the required R packages, are fixed and
constant for a particular application.</p>
<p>The main challenges in using Docker with renv are:</p>
<ul>
<li><p>Ensuring that the renv cache is visible to Docker containers,
and</p></li>
<li><p>Ensuring that required R package dependencies are available at
run-time.</p></li>
</ul>
<p>This vignette will assume you are already familiar with Docker; if
you are not yet familiar with Docker, the <a href="https://docs.docker.com/">Docker Documentation</a> provides a
thorough introduction. To learn more about using Docker to manage R
environments, visit <a href="https://environments.rstudio.com/docker.html">environments.rstudio.com</a>.</p>
<p>We’ll discuss two strategies for using renv with Docker:</p>
<ol style="list-style-type: decimal">
<li>Using renv to install packages when the Docker image is
generated;</li>
<li>Using renv to install packages when Docker containers are run.</li>
</ol>
<p>We’ll also explore the pros and cons of each strategy.</p>
<div id="creating-docker-images-with-renv" class="section level2">
<h2>Creating Docker images with renv</h2>
<p>With Docker, <a href="https://docs.docker.com/engine/reference/builder/">Dockerfiles</a>
are used to define new images. Dockerfiles can be used to declaratively
specify how a Docker image should be created. A Docker image captures
the state of a machine at some point in time – e.g., a Linux operating
system after downloading and installing R 4.4. Docker containers can be
created using that image as a base, allowing different independent
applications to run using the same pre-defined machine state.</p>
<p>First, you’ll need to get renv installed on your Docker image. The
easiest way to accomplish this is with the <code>remotes</code> package.
For example, you could install the latest release of <code>renv</code>
from CRAN:</p>
<pre><code>RUN R -e &quot;install.packages(&#39;renv&#39;, repos = c(CRAN = &#39;https://cloud.r-project.org&#39;))&quot;</code></pre>
<p>Alternatively, if you needed to use the development version of
<code>renv</code>, you could use:</p>
<pre><code>RUN R -e &quot;install.packages(&#39;remotes&#39;, repos = c(CRAN = &#39;https://cloud.r-project.org&#39;))&quot;
RUN R -e &quot;remotes::install_github(&#39;rstudio/renv&#39;)&quot;</code></pre>
<p>Next, if you’d like the <code>renv.lock</code> lockfile to be used to
install R packages when the Docker image is built, you’ll need to copy
it to the container:</p>
<pre><code>WORKDIR /project
COPY renv.lock renv.lock</code></pre>
<p>Next, you need to tell renv which library paths to use for package
installation. You can either set the <code>RENV_PATHS_LIBRARY</code>
environment variable to a writable path within your Docker container, or
copy the renv auto-loader tools into the container so that a
project-local library can be automatically provisioned and used when R
is launched.</p>
<pre><code># approach one
ENV RENV_PATHS_LIBRARY renv/library

# approach two
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json</code></pre>
<p>Finally, you can run <code>renv::restore()</code> to restore packages
as defined in the lockfile:</p>
<pre><code>RUN R -e &quot;renv::restore()&quot;</code></pre>
<p>With this, renv will download and install the requisite packages as
appropriate when the image is created. Any new containers created from
this image will hence have those R packages installed and visible at
run-time.</p>
</div>
<div id="speeding-up-package-installations" class="section level2">
<h2>Speeding up package installations</h2>
<p>The aforementioned approach is useful if you have multiple
applications with identical package requirements. In this case, a single
image containing this identical package library could serve as the
parent image for several containerized applications.</p>
<p>However, <code>renv::restore()</code> is slow – it needs to download
and install packages, which can take some time. Thus, some care is
required to efficiently make use of the <code>renv</code> cache for
projects that require:</p>
<ol style="list-style-type: decimal">
<li><p>Building an image multiple times (e.g., to debug the production
application as source code is updated), or</p></li>
<li><p>Calling <code>renv::restore()</code> each time the container is
run.</p></li>
</ol>
<p>The former process can be sped up using multi-stage builds, the
latter by dynamically provisioning R Libraries, as described below.</p>
<div id="multi-stage-builds" class="section level3">
<h3>Multi-stage builds</h3>
<p>For projects that require repeatedly building an image, <a href="https://docs.docker.com/build/building/multi-stage/">multi-stage
builds</a> can be used to speed up the build process. With multi-stage
builds, multiple FROM statements are used in the Dockerfile and files
can be copied across build stages.</p>
<p>This approach can be leveraged to generate more efficient builds by
dedicating a first stage build to package synchronization and a second
stage build to copying files and executing code that may need to be
updated often across builds (e.g., code that needs to be debugged in the
container).</p>
<p>To implement a two stage build, the following code could be used as
part of a Dockerfile.</p>
<pre><code># STAGE 1: renv-related code
FROM &lt;parent_image&gt; AS base

WORKDIR /project

# using approach 2 above
RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.dcf renv/settings.dcf

# change default location of cache to project folder
RUN mkdir renv/.cache
ENV RENV_PATHS_CACHE renv/.cache

# restore 
RUN R -e &quot;renv::restore()&quot;</code></pre>
<p>The above code uses
<code>FROM &lt;parent_image&gt; AS &lt;name&gt;</code> to name the first
stage of the build <code>base</code>. Here,
<code>&lt;parent_image&gt;</code> should be replaced with an appropriate
image name.</p>
<p>Subsequently, the code uses approach 2 (described above) to copy the
auto-loader to the project directory in the image. It additionally
creates the <code>renv/.cache</code> directory that is to be used as the
<code>renv</code> cache.</p>
<p>The second stage of the build is defined by adding the following code
to the same Dockerfile, below the previous code chunk.</p>
<pre><code>FROM &lt;parent_image&gt;

WORKDIR /project
COPY --from=base /project .

# add commands that need to be debugged below</code></pre>
<p>Here, <code>&lt;parent_image&gt;</code> could be the same as the
parent image of <code>base</code>, but does not have to be (see <a href="https://docs.docker.com/build/building/multi-stage/">documentation</a>
for more details).</p>
<p>The key line is the <code>COPY</code> command, which specifies that
the contents of <code>/project</code> directory from the
<code>base</code> image are copied into the <code>/project</code>
directory of this image.</p>
<p>Any commands that will change frequently across builds could be
included below the <code>COPY</code> command. If only this code
associated with the second stage build is updated then
<code>renv::restore()</code> will not be called again at build time.
Instead, the layers associated with the <code>base</code> image will be
loaded from Docker’s cache, thereby saving significant time in build
process.</p>
<p>In fact, <code>renv::restore()</code> will only be called when the
<code>base</code> image needs to be rebuilt (e.g., when changes are made
to <code>renv.lock</code>). Docker’s cache system is generally good at
understanding the dependencies of images. However, if you find that the
<code>base</code> image is not updating as expected, it is possible to
manually enforce a clean build by including the <code>--no-cache</code>
option in the call to <code>docker build</code>.</p>
</div>
<div id="dynamically-provisioning-r-libraries-with-renv" class="section level3">
<h3>Dynamically Provisioning R Libraries with renv</h3>
<p>However, on occasion, one will have multiple applications built from
a single base image, but each application will have its own independent
R package requirements. In this case, rather than including the package
dependencies in the image itself, it would be preferable for each
container to provision its own library at run-time, based on that
application’s <code>renv.lock</code> lockfile.</p>
<p>In effect, this is as simple as ensuring that
<code>renv::restore()</code> happens at container run-time, rather than
image build time. However, on its own, <code>renv::restore()</code> is
slow – it needs to download and install packages, which could take
prohibitively long if an application needs to be run repeatedly.</p>
<p>The renv package cache can be used to help ameliorate this issue.
When the cache is enabled, whenever renv attempts to install or restore
an R package, it first checks to see whether that package is already
available within the renv cache. If it is, that instance of the package
is linked into the project library. Otherwise, the package is first
installed into the renv cache, and then that newly-installed copy is
linked for use in the project.</p>
<p>In effect, if the renv cache is available, you should only need to
pay the cost of package installation once – after that, the
newly-installed package will be available for re-use across different
projects. At the same time, each project’s library will remain
independent and isolated from one another, so installing a package
within one container won’t affect another container.</p>
<p>However, by default, each Docker container will have its own
independent filesystem. Ideally, we’d like for <em>all</em> containers
launched from a particular image to have access to the same renv cache.
To accomplish this, we’ll have to tell each container to use an renv
cache located on a shared mount.</p>
<p>In sum, if we’d like to allow for run-time provisioning of R package
dependencies, we will need to ensure the renv cache is located on a
shared volume, which is visible to any containers launched. We will
accomplish this by:</p>
<ol style="list-style-type: decimal">
<li><p>Setting the <code>RENV_PATHS_CACHE</code> environment variable,
to tell the instance of renv running in each container where the global
cache lives;</p></li>
<li><p>Telling Docker to mount some filesystem location from the host
filesystem, at some location (<code>RENV_PATHS_CACHE_HOST</code>), to a
container-specific location
(<code>RENV_PATHS_CACHE_CONTAINER</code>).</p></li>
</ol>
<p>For example, if you had a container running a Shiny application:</p>
<pre><code># the location of the renv cache on the host machine
RENV_PATHS_CACHE_HOST=/opt/local/renv/cache

# where the cache should be mounted in the container
RENV_PATHS_CACHE_CONTAINER=/renv/cache

# run the container with the host cache mounted in the container
docker run --rm \
    -e &quot;RENV_PATHS_CACHE=${RENV_PATHS_CACHE_CONTAINER}&quot; \
    -v &quot;${RENV_PATHS_CACHE_HOST}:${RENV_PATHS_CACHE_CONTAINER}&quot; \
    -p 14618:14618 \
    R -s -e &#39;renv::restore(); shiny::runApp(host = &quot;0.0.0.0&quot;, port = 14618)&#39;</code></pre>
<p>With this, any calls to renv APIs within the created docker container
will have access to the mounted cache. The first time you run a
container, renv will likely need to populate the cache, and so some time
will be spent downloading and installing the required packages.
Subsequent runs will be much faster, as renv will be able to reuse the
global package cache.</p>
<p>The primary downside with this approach compared to the image-based
approach is that it requires you to modify how containers are created,
and requires a bit of extra orchestration in how containers are
launched. However, once the renv cache is active, newly-created
containers will launch very quickly, and a single image can then be used
as a base for a myriad of different containers and applications, each
with their own independent package dependencies.</p>
</div>
</div>
<div id="handling-the-renv-autoloader" class="section level2">
<h2>Handling the renv autoloader</h2>
<p>When <code>R</code> is launched within a project folder, the renv
auto-loader (if present) will attempt to download and install renv into
the project library. Depending on how your Docker container is
configured, this could fail. For example:</p>
<pre><code>Error installing renv:
======================
ERROR: unable to create &#39;/usr/local/pipe/renv/library/master/R-4.0/x86_64-pc-linux-gnu/renv&#39;
Warning messages:
1: In system2(r, args, stdout = TRUE, stderr = TRUE) :
  running command &#39;&#39;/usr/lib/R/bin/R&#39; --vanilla CMD INSTALL -l &#39;renv/library/master/R-4.0/x86_64-pc-linux-gnu&#39; &#39;/tmp/RtmpwM7ooh/renv_0.12.2.tar.gz&#39; 2&gt;&amp;1&#39; had status 1
2: Failed to find an renv installation: the project will not be loaded.
Use `renv::activate()` to re-initialize the project.</code></pre>
<p>Bootstrapping renv into the project library might be unnecessary for
you. If that is the case, then you can avoid this behavior by launching
R with the <code>--vanilla</code> flag set; for example:</p>
<pre><code>R --vanilla -s -e &#39;renv::restore()&#39;</code></pre>
</div>



<!-- code folding -->


<!-- dynamically load mathjax for compatibility with self-contained -->
<script>
  (function () {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src  = "https://mathjax.rstudio.com/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML";
    document.getElementsByTagName("head")[0].appendChild(script);
  })();
</script>

</body>
</html>
