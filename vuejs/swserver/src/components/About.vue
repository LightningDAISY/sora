<template>
<div class="container">
  <Nav />
  <section class="hero is-light is-bold">
    <div class="hero-body">
      <div class="container">
        <h1 class="title">
          About LightningDAISY
        </h1>
        <h2 class="subtitle">
          Producing high-quality frontend and high-performance backend
        </h2>
      </div>
    </div>
  </section>

  <div class="tile is-ancestor" style="margin-top: 40px">
    <div class="tile is-vertical is-12">
      <div class="tile">
        <div class="tile is-parent is-vertical">
          <article class="tile is-child is-light">
            <p class="subtitle">
              <img src="/static/images/lightningdaisy.jpg" />
            </p>
          </article>

          <article class="tile is-child notification is-light">
            <p class="title">Love</p>
            <p class="subtitle">Swift, Lua, ES6, CSS3, Crystal</p>
          </article>
          <article class="tile is-child notification is-light">
            <p class="title">Like</p>
            <p class="subtitle">Perl, Lisp, Elixir, Rust</p>
          </article>
          <article class="tile is-child notification is-light">
            <p class="title">Can</p>
            <p class="subtitle">C, Ruby, PHP, Java, Go, nim, etc...</p>
          </article>
        </div>
        <div class="tile is-parent">
          <article class="tile is-child">
            <div class="card">
              <div class="card-content">
                <div class="content align-left">
                  I am a Server-side &amp; Front-end Developer.
                  I have 10 years commercial experience providing development,
                  producing high quality responsive websites and Server-side engineer leader.
                </div>
              </div>
            </div>
            <div class="card">
              <div class="card-content">
                <div class="content align-left">
                  Clients often approach me when they need a developer who can provide:
                </div>
                <div class="content align-left">
                  <table>
                    <tr><td>Network and Infracture(Performance, Best practice)</td></tr>
                    <tr><td>Cloud Services</td></tr>
                    <tr><td>Daemons (Openresty, Apache, Redis, DBMS...)</td></tr>
                    <tr><td>API and BFF Design</td></tr>
                    <tr><td>Development</td></tr>
                    <tr><td>Responsive HTML/CSS</td></tr>
                  </table>
                </div>
                <div class="content align-left">
                  I take care to ensure each project is well-documented and easily maintainable
                  so you can enhance a website as your company grows.
                </div>
                <div class="content align-left">
                  <p class="title">Contact</p>
                  <p class="margin-top-small">
                    You can send me messages on Twitter or this website. 
                    And recommend me some happy works, interesting conferences and good PlayStation4-games.
                  </p>
                </div>
              </div>
            </div>
          </article>
        </div>
      </div>
    </div>
  </div>


  <Footer />

</div>
</template>

<script>
import Nav from './Nav'
import Footer from './Footer'
import Base from './Base'

export default {
  name: 'About',
  mixins: [Base],
  methods: {
  },
  data () {
    return {
      title: 'About'
    }
  },
  mounted: function () {
    document.title = this.title
  },
  components: {
    Nav, Footer
  }
}
</script>

<style scoped>
</style>

