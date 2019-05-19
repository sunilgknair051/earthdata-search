import React, { Component } from 'react'
import { Helmet } from 'react-helmet'
import { Provider } from 'react-redux'
import { ConnectedRouter } from 'connected-react-router'
import { Switch, Route, Redirect } from 'react-router-dom'

import store from './store/configureStore'
import history from './util/history'

import FooterContainer from './containers/FooterContainer/FooterContainer'

import Search from './routes/Search/Search'
import Project from './routes/Project/Project'
import ConnectedUrlQueryContainer from './containers/UrlQueryContainer/UrlQueryContainer'
import ConnectedAuthContainer from './containers/AuthContainer/AuthContainer'

// if (process.env.NODE_ENV !== 'production') {
//   const whyDidYouRender = require('@welldone-software/why-did-you-render') // eslint-disable-line global-require
//   whyDidYouRender(React, { include: [/Search/] })

//   const { whyDidYouUpdate } = require('why-did-you-update') // eslint-disable-line global-require
//   whyDidYouUpdate(React, { include: [/Search/] })
// }

// Create the root App component
class App extends Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  render() {
    return (
      <Provider store={store}>
        <ConnectedRouter history={history}>
          <ConnectedAuthContainer>
            <ConnectedUrlQueryContainer>
              <Helmet>
                <meta charSet="utf-8" />
                <title>Earthdata Search</title>
              </Helmet>
              <Switch>
                <Route exact path="/">
                  <Redirect to="/search" />
                </Route>
                <Route path="/search" component={Search} />
                <Route path="/project" component={Project} />
              </Switch>
              <FooterContainer />
            </ConnectedUrlQueryContainer>
          </ConnectedAuthContainer>
        </ConnectedRouter>
      </Provider>
    )
  }
}

export default App