import React, { Component, cloneElement } from 'react'
import PropTypes from 'prop-types'
import classNames from 'classnames'

import EDSCModal from '../../components/EDSCModal/EDSCModal'

/**
 * Renders EDSCModal.
 * @param {Element} body The modal body content.
 * @param {Boolean} bodyPadding Sets the padding on the inner body.
 * @param {String} className An optional classname for the modal.
 * @param {Boolean} fixedHeight Sets the modal to fixed height.
 * @param {Element} footer The footer content.
 * @param {Element} footerMeta The footer meta content.
 * @param {String} id A unique id for the modal.
 * @param {Boolean} isOpen A flag that designates the modal open or closed.
 * @param {Element} innerHeader An element for the innerHeader.
 * @param {Function} onClose A callback to be fired when the modal close is triggered.
 * @param {String} title The modal title.
 * @param {String} size The size to be passed to the Bootstrap modal.
 * @param {Boolean} spinner Shows a loading spinner.
 * @param {String} primaryAction The text content for the primary action.
 * @param {Boolean} primaryActionDisabled Disables the primary action.
 * @param {String} secondaryAction The text content for the secondary action.
 * @param {Function} onPrimaryAction A callback function for the primary action.
 * @param {Function} onSecondaryAction A callback function for the secondary action.
 */
export class EDSCModalContainer extends Component {
  constructor(props) {
    super(props)

    this.modalInner = React.createRef()

    this.onSetOverlayModalContent = this.onSetOverlayModalContent.bind(this)
    this.onModalExit = this.onModalExit.bind(this)
    this.onModalHide = this.onModalHide.bind(this)

    this.state = {
      modalOverlay: null
    }
  }

  onSetOverlayModalContent(overlay) {
    this.setState({
      modalOverlay: overlay || null
    })
  }

  onModalHide() {
    const { onClose } = this.props
    if (onClose) onClose(false)
  }

  onModalExit() {
    this.setState({
      modalOverlay: null
    })
  }

  render() {
    const {
      body,
      bodyPadding,
      className,
      size,
      fixedHeight,
      footer,
      footerMeta,
      id,
      innerHeader,
      isOpen,
      title,
      primaryAction,
      primaryActionDisabled,
      secondaryAction,
      spinner,
      onPrimaryAction,
      onSecondaryAction,
      modalOverlays
    } = this.props

    const {
      modalOverlay
    } = this.state

    const identifier = `edsc-modal__${id}-modal`

    const modalClassNames = classNames([
      'edsc-modal',
      identifier,
      {
        [`${className}`]: className,
        [`edsc-modal--fixed-height-${fixedHeight}`]: fixedHeight,
        'edsc-modal--fixed-height': fixedHeight,
        'edsc-modal--inner-header': innerHeader,
        'edsc-modal--body-padding': bodyPadding
      }
    ])

    let activeModalOverlay = null

    if (modalOverlay && modalOverlays[modalOverlay]) {
      activeModalOverlay = modalOverlays[modalOverlay]
    }

    const addPropsToChildren = (el) => {
      if (el) {
        return cloneElement(el, {
          setModalOverlay: (overlay) => {
            this.onSetOverlayModalContent(overlay)
          },
          modalInnerRef: this.modalInner
        })
      }
      return null
    }

    // Loop through the custom elements and attach the extra props we want to pass
    const [
      innerHeaderEl,
      bodyEl,
      modalOverlayEl
    ] = [
      innerHeader,
      body,
      activeModalOverlay
    ].map(addPropsToChildren)

    return (
      <EDSCModal
        activeModalOverlay={activeModalOverlay}
        bodyEl={bodyEl}
        footer={footer}
        footerMeta={footerMeta}
        identifier={identifier}
        innerHeaderEl={innerHeaderEl}
        isOpen={isOpen}
        modalClassNames={modalClassNames}
        modalInner={this.modalInner}
        modalOverlayEl={modalOverlayEl}
        onModalExit={this.onModalExit}
        onModalHide={this.onModalHide}
        onPrimaryAction={onPrimaryAction}
        onSecondaryAction={onSecondaryAction}
        primaryAction={primaryAction}
        primaryActionDisabled={primaryActionDisabled}
        secondaryAction={secondaryAction}
        size={size}
        spinner={spinner}
        title={title}
      />
    )
  }
}

export default EDSCModalContainer

EDSCModalContainer.defaultProps = {
  bodyPadding: true,
  className: '',
  fixedHeight: false,
  footer: null,
  footerMeta: null,
  innerHeader: null,
  onClose: null,
  title: null,
  size: 'sm',
  spinner: false,
  modalOverlays: {},
  primaryAction: null,
  primaryActionDisabled: false,
  secondaryAction: null,
  onPrimaryAction: null,
  onSecondaryAction: null
}

EDSCModalContainer.propTypes = {
  body: PropTypes.node.isRequired,
  bodyPadding: PropTypes.bool,
  className: PropTypes.string,
  fixedHeight: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.bool
  ]),
  footer: PropTypes.node,
  footerMeta: PropTypes.node,
  id: PropTypes.string.isRequired,
  innerHeader: PropTypes.node,
  isOpen: PropTypes.bool.isRequired,
  modalOverlays: PropTypes.shape({}),
  onClose: PropTypes.func,
  title: PropTypes.string,
  size: PropTypes.string,
  spinner: PropTypes.bool,
  primaryAction: PropTypes.string,
  primaryActionDisabled: PropTypes.bool,
  secondaryAction: PropTypes.string,
  onPrimaryAction: PropTypes.func,
  onSecondaryAction: PropTypes.func
}