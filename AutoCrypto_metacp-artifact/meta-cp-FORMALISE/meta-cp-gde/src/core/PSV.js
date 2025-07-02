import React from 'react';

/**
 * Decorate the component accepting a reference
 */
export default function psv(MetaCPComponent) {
  class PSV extends React.Component {
    render() {
      const {forwardedRef, ...rest} = this.props;
      return (
        <MetaCPComponent ref={forwardedRef} {...rest} />
      );
    }
  }
  
  return React.forwardRef((props, ref) => {
    return <PSV {...props} forwardedRef={ref} />;
  });
}
